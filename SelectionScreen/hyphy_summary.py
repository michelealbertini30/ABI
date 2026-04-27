import os
import re
import argparse
import pandas as pd

def parse_busted(file_path, pvalue):
    with open(file_path) as f:
        content = f.read()

    # Extract the total number of codons
    total_sites_match = re.search(r'\*\*(\d+)\*\* codons', content)
    total_sites = int(total_sites_match.group(1)) if total_sites_match else 0

    # Extract the p-value
    p_match = re.search(r'Likelihood ratio test for episodic diversifying positive selection, \*\*p =\s*([0-9.eE-]+)\*\*', content)
    if p_match:
        pval = float(p_match.group(1))
        if pval >= pvalue:
            return f'NS (p={pval})'  # Not significant

        # Extract the proportion of sites under diversifying selection
        div_selection_match = re.search(r'Diversifying selection\s*\|\s*[0-9.eE-]+\s*\|\s*([0-9.eE-]+)\s*\|', content)
        if div_selection_match:
            div_proportion = float(div_selection_match.group(1))
            return f"(DivSel) {div_proportion:.3f}% of sites"

    return 'NA'


def parse_meme(file_path, pvalue):
    with open(file_path) as f:
        content = f.read()

    total_sites_match = re.search(r'\*\*(\d+)\*\* codons', content)
    total_sites = int(total_sites_match.group(1)) if total_sites_match else 0

    summary_match = re.search(
        r'Found\s+_(\d+)_\s+sites under episodic diversifying positive selection at p\s*<=\s*[0-9.eE-]+',
        content
    )
    if summary_match:
        return int(summary_match.group(1))

    sites = re.findall(r'Site\s+\d+\s+p\s*=\s*([0-9.eE-]+)', content)
    selected = [s for s in sites if float(s) < pvalue]
    return len(selected)


def parse_absrel(file_path, pvalue):
    with open(file_path) as f:
        content = f.read()

    if "### Testing selected branches for selection" in content:
        content = content.split("### Testing selected branches for selection", 1)[1]

    rows = []
    for line in content.splitlines():
        line = line.strip()
        if not line.startswith("|") or 'Branch' in line:
            continue
        match = re.match(r'\|\s*([^\|]+?)\s*\|.*\|\s*([0-9.eE-]+)\s*\|$', line)
        if match:
            branch, pval = match.groups()
            try:
                pval = float(pval)
                rows.append((branch.strip(), pval))
            except ValueError:
                continue

    if not rows:
        return 0, []

    sorted_rows = sorted(rows, key=lambda x: x[1])
    n_tests = len(sorted_rows)
    selected_branches = []

    for i, (branch, pval) in enumerate(sorted_rows):
        corrected_p = pval * (n_tests - i)
        corrected_p = min(corrected_p, 1.0)
        if corrected_p < pvalue:
            selected_branches.append(branch)
        else:
            break

    return len(selected_branches), selected_branches


def parse_fubar(file_path, pvalue):
    with open(file_path) as f:
        content = f.read()
    selected_sites = re.findall(r'Posterior probability > ([0-9.eE-]+) at site (\d+)', content)
    selected = [site for prob, site in selected_sites if float(prob) >= pvalue]
    return len(selected)


def parse_slac_selection(file_path, pvalue):
    with open(file_path) as f:
        content = f.read()

    # Extract the total number of codons
    codon_match = re.search(r'Loaded a multiple sequence alignment with \*\*\d+\*\* sequences, \*\*(\d+)\*\* codons', content)
    total_sites = int(codon_match.group(1)) if codon_match else 0

    # Extract negative selection sites
    neg_sites = re.findall(r'Neg\. p = ([0-9.eE-]+)', content)
    neg_selected = [float(p) for p in neg_sites if float(p) <= pvalue]

    # Extract positive selection sites
    pos_sites = re.findall(r'Pos\. p = ([0-9.eE-]+)', content)
    pos_selected = [float(p) for p in pos_sites if float(p) <= pvalue]

    return len(neg_selected), len(pos_selected), total_sites


def summarize(folder, meme_p, absrel_p, busted_p, slac_p, fubar_p):
    results = []

    # Check if the folder contains any .out files
    out_files = [filename for filename in os.listdir(folder) if filename.endswith('.out')]
    if not out_files:
        print("No .out files found in the specified folder.")
        return results

    for filename in sorted(out_files):
        filepath = os.path.join(folder, filename)

        if 'meme' in filename.lower():
            n = parse_meme(filepath, meme_p)
            test = 'MEME'
            branches = '-'
            selected = n
        elif 'busted' in filename.lower():
            selected = parse_busted(filepath, busted_p)
            test = 'BUSTED'
            branches = '-'
        elif 'absrel' in filename.lower():
            selected, branches_list = parse_absrel(filepath, absrel_p)
            test = 'aBSREL'
            branches = ', '.join(branches_list) if branches_list else '-'
        elif 'fubar' in filename.lower():
            selected = parse_fubar(filepath, fubar_p)
            test = 'FUBAR'
            branches = '-'
        elif 'slac' in filename.lower():
            neg, pos, total = parse_slac_selection(filepath, slac_p)
            test = 'SLAC'
            if total == 0:
                selected = f"(NegSel) {neg}/{total}=N/A (PosSel) {pos}/{total}=N/A"
            else:
                selected = f"(NegSel) {neg}/{total}={neg/total:.3f} (PosSel) {pos}/{total}={pos/total:.3f}"
            branches = '-'
        else:
            selected = 'NA'
            test = 'UNKNOWN'
            branches = '-'

        results.append({'FILE': filename, 'TEST': test, 'SELECTED': selected, 'BRANCHES': branches})

    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Summarize the results of HyPhy selection analyses from a specified folder containing the redirected stdout outputs of HyPhy analyses. Files can have arbitrary names but must include the analysis type (e.g. slac) in lowercase and have a .out file extension.')
    parser.add_argument('folder', help='Folder with HyPhy .out files')
    parser.add_argument('--meme_p', type=float, default=0.05, help='MEME p-value threshold')
    parser.add_argument('--busted_p', type=float, default=0.05, help='BUSTED p-value threshold')
    parser.add_argument('--absrel_p', type=float, default=0.05, help='aBSREL p-value threshold')
    parser.add_argument('--slac_p', type=float, default=0.05, help='SLAC p-value threshold')
    parser.add_argument('--fubar_p', type=float, default=0.9, help='FUBAR posterior probability threshold')
    parser.add_argument('--output_csv', type=str, help='Specify the name of the CSV output file')

    args = parser.parse_args()
    results = summarize(args.folder, args.meme_p, args.absrel_p, args.busted_p, args.slac_p, args.fubar_p)

    if not results:
        print("No results to summarize. Please check your input files.")
    else:
        # Convert results to a DataFrame
        df = pd.DataFrame(results)

        # Print the DataFrame
        print(df.to_string(index=False))

        # Save the DataFrame to a CSV file if the --output_csv flag is provided
        if args.output_csv:
            df.to_csv(args.output_csv, index=False)
            print(f"\nSummary saved to {args.output_csv}")