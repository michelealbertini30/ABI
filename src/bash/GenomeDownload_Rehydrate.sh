#!/bin/bash

input_file=$1

if [ ! -f "$input_file" ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

mkdir -p Genomes

echo "Step 1: Parsing accessions..."

accessions=$(awk '!/^#/ {print $1}' "$input_file")

echo "Step 2: Downloading dehydrated genomes..."

for rf in $accessions; do
    echo "Downloading $rf ..."
    datasets download genome accession "$rf" \
        --include genome \
        --dehydrated \
        --filename "$rf.zip"
done

echo "Step 3: Unzipping and rehydrating..."

for rf in $accessions; do
    if [ -f "$rf.zip" ]; then
        unzip -o "$rf.zip" -d "$rf"

        echo "Rehydrating $rf ..."
        datasets rehydrate --directory "$rf"

        rm -f "$rf.zip"
    else
        echo "Warning: $rf.zip not found, skipping"
    fi
done

echo "Step 4: Extracting FASTA genomes..."

while read -r line; do
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    ref=$(echo "$line" | awk '{print $1}')
    ids=$(echo "$line" | awk '{print $2}')

    fasta_file=$(find "$ref" -path "*ncbi_dataset/data/$ref/*.fna" 2>/dev/null | head -n 1)

    if [ -f "$fasta_file" ]; then
        cp "$fasta_file" "Genomes/${ids}.fna"
        echo "Copied ${ids}.fna"
    else
        echo "Warning: no .fna found for $ref"
    fi

done < "$input_file"

echo "Done."

