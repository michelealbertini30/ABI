#!/bin/bash
input_fasta_file=$1
true_genes_file=$2

# Check if input files exist
if [ ! -f "$input_fasta_file" ]; then
    echo "Input fasta file $input_fasta_file not found."
    exit 1
fi

if [ ! -f "$true_genes_file" ]; then
    echo "True genes file $true_genes_file not found."
    exit 1
fi

# Create a temporary file to store the filtered fasta
temp_file=$(mktemp)

# Read true genes into an associative array for quick lookup
declare -A true_genes
while IFS= read -r gene; do
    true_genes["$gene"]=1
done < "$true_genes_file"

# Read the input fasta file and filter out genes not in the true genes list
current_gene=""
print_gene=false
while IFS= read -r line; do
    if [[ $line == ">"* ]]; then
        current_gene="${line:1}"
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

mv "$temp_file" "Filtered.fa"
