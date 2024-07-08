#!/bin/bash

dir=$1
names=$2

declare -A protein_dict

# Read the names file and populate the dictionary
while IFS=$'\t' read -r protein right_protein; do
    protein_dict["$protein"]="$right_protein"
done < "$names"

# Iterate over each .besthit file in the specified directory
for file in "$dir"/*top.2; do
    output_file="${file/.top.2/.abi}"

    # Read the .besthit file line by line
    while IFS=$'\t' read -r gene protein rest; do
        # Substitute the second field if it exists in the dictionary
        if [[ -n "${protein_dict[$protein]}" ]]; then
            echo -e "$gene\t${protein_dict[$protein]}\t$rest"
        else
            echo -e "$gene\t$protein\t$rest"
        fi
    done < "$file" > "$output_file"
done

echo "Substitution completed. Check the output files for results."
