import sys

def process_fasta(input_file):
    # Define replacement rules
    replacements = {
        "A": "A", "G": "A", "N": "A", "P": "A", "S": "A", "T": "A",
        "C": "C", "H": "C", "W": "C", "Y": "C",
        "D": "G", "E": "G", "K": "G", "Q": "G", "R": "G",
        "F": "T", "I": "T", "L": "T", "M": "T", "V": "T"
    }

    # Define the output file name
    output_file = f"{input_file}.recoded"

    try:
        with open(input_file, "r") as infile, open(output_file, "w") as outfile:
            for line in infile:
                if line.startswith(">"):
                    # Write headers as-is
                    outfile.write(line)
                else:
                    processed_line = []
                    for aa in line.strip():
                        if aa == "X":
                            # Skip 'X'
                            continue
                        elif aa in replacements:
                            # Replace valid amino acids
                            processed_line.append(replacements[aa])
                        else:
                            # Raise an error for undefined amino acids
                            raise ValueError(f"Undefined amino acid '{aa}' found in sequence.")
                    # Write the processed sequence
                    outfile.write("".join(processed_line) + "\n")
        print(f"Processed file saved to {output_file}")

    except ValueError as e:
        # Handle undefined amino acid errors
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found.", file=sys.stderr)
        sys.exit(1)

# Main script execution
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python replace_amino_acids.py <input_fasta_file>")
        sys.exit(1)

    input_fasta = sys.argv[1]
    process_fasta(input_fasta)
