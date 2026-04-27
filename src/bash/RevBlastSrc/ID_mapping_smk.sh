#!/bin/bash

file=$1
ids=$2
output=$3

declare -A protein_dict

# Read the names file and populate the dictionary
while IFS=$'\t' read -r protein right_protein; do
    protein_dict["$protein"]="$right_protein"
done < "$ids"

while IFS=$'\t' read -r gene protein rest; do
	if [[ -n "${protein_dict[$protein]}" ]]; then
        	echo -e "$gene\t${protein_dict[$protein]}\t$rest"
        else
        	echo -e "$gene\t$protein\t$rest"
        fi
done < "$file" > "$output"

