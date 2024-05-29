#!/bin/bash

# Directory containing input fasta files
input_dir=$1

echo "Starting fasta filtering ..."

# Check the existence of given directory
if [ ! -d "$input_dir" ]; then
    echo "Input directory $input_dir not found."
    exit 1
fi

# Loop through all fasta files and generate its corresponding .txt file
for input_fasta_file in "$input_dir"/*.aa; do
	base_name=$(basename "$input_fasta_file" augustus.aa)
	true_genes_file_name="${base_name}.truep450.txt"

	# Check for true genes file existence
	if [ ! -f "$true_genes_file_name" ]; then
		echo "True genes file $true_genes_file_name not found."
		exit 1
	fi

	# Create a temporary file to store the filtered fasta
	temp_file=$(mktemp)

	# Read true genes into an associative array for quick lookup
	unset true_genes

	declare -A true_genes
	while IFS= read -r gene; do
		true_genes["$gene"]=1
	done < "$true_genes_file_name"

	# Read the input fasta file and filter out genes not in the true genes list
	current_gene=""
	print_gene=false
	while IFS= read -r line; do
		if [[ $line == ">"* ]]; then
			# Read line starting from the second (exclude header)
			current_gene="${line:1}"

			# If current gene is in true genes array, switch to print_gene=true
			if [ -n "${true_genes[$current_gene]}" ]; then
				print_gene=true
				echo "$line" >> "$temp_file"
			else
				print_gene=false
			fi
		else
			if [ "$print_gene" = true ]; then
				echo "$line" >> "$temp_file"
			fi
		fi
	done < "$input_fasta_file"

	# Rename the temporary file to use the base name of the input file
	final_file="${base_name}.filtered.fa"
	mv "$temp_file" "$final_file"

	echo "Filtered file created: $final_file"
done
