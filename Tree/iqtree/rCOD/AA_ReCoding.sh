#!/bin/bash

# Check if input file is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_fasta_file>"
    exit 1
fi

input_file=$1
output_file="$1".recoded

# Process the input FASTA file
awk '
BEGIN {
    # Define replacement rules
    replace["A"] = "A"; replace["G"] = "A"; replace["N"] = "A"; replace["P"] = "A"; replace["S"] = "A"; replace["T"] = "A";
    replace["C"] = "C"; replace["H"] = "C"; replace["W"] = "C"; replace["Y"] = "C";
    replace["D"] = "G"; replace["E"] = "G"; replace["K"] = "G"; replace["Q"] = "G"; replace["R"] = "G";
    replace["F"] = "T"; replace["I"] = "T"; replace["L"] = "T"; replace["M"] = "T"; replace["V"] = "T";
}
{
    if ($0 ~ /^>/) {
        # Print header lines as is
        print $0
    } else {
        # Process sequence lines
        seq = $0
        for (i = 1; i <= length(seq); i++) {
            aa = substr(seq, i, 1)
            if (aa == "X") {
                # Skip X without printing
                continue
            } else if (aa in replace) {
                # Replace defined amino acids
                printf "%s", replace[aa]
            } else {
                # Print error and exit if an undefined amino acid is found
                printf "Error: Undefined amino acid '%s' found at line %d\n", aa, NR > "/dev/stderr"
                exit 1
            }
        }
        print ""  # Newline after sequence
    }
}' "$input_file" > "$output_file"

if [ $? -eq 0 ]; then
    echo "Processed file saved to $output_file"
else
    echo "Processing terminated due to an error."
    rm -f "$output_file"  # Clean up output file if there was an error
fi
