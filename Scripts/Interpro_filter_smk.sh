#!/bin/bash

# Directory containing input fasta files
fasta=$1
txt=$2
out=$3

base_name=$(basename "$fasta" .augustus.aa)

declare -A true_genes
while IFS= read -r gene; do
	true_genes["$gene"]=1
done < "$txt"

current_gene=""
print_gene=false
while IFS= read -r line; do
	if [[ $line == ">"* ]]; then
		current_gene="${line:1}"

		if [ -n "${true_genes[$current_gene]}" ]; then
			print_gene=true
			echo "$line" >> "$out"
		else
			print_gene=false
		fi
	else
		if [ "$print_gene" = true ]; then
			echo "$line" >> "$out"
		fi
	fi

touch "$out"
done < "$fasta"

echo "Filtered file created: ${out}"

