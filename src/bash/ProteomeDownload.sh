#!/bin/bash

input_file=$1

if [ ! -f "$input_file" ]; then
    echo "Input file not found: $input_file"
    exit 1
fi

mkdir -p Proteoms

echo "Step 1: Parsing accessions..."

# Extract valid accessions (skip comments)
accessions=$(awk '!/^#/ {print $1}' "$input_file")

echo "Step 2: Downloading genomes..."

for rf in $accessions; do
    echo "Downloading $rf ..."
    datasets download genome accession "$rf" --include protein --filename "$rf.zip"
done

echo "Step 3: Unzipping datasets..."

for rf in $accessions; do
    if [ -f "$rf.zip" ]; then
        unzip -o "$rf.zip" -d "$rf"

        if [ -d "$rf" ]; then
            rm "$rf.zip"
        fi
    else
        echo "Warning: $rf.zip not found, skipping unzip"
    fi
done

echo "Step 4: Extracting protein FASTA files..."

while read -r line; do
    # skip comments and empty lines
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue

    ref=$(echo "$line" | awk '{print $1}')
    ids=$(echo "$line" | awk '{print $4}')

    faa_file=$(find "$ref" -path "*ncbi_dataset/data/$ref/*.faa" 2>/dev/null | head -n 1)

    if [ -f "$faa_file" ]; then
        cp "$faa_file" "Proteoms/${ids}.faa"
        echo "Copied ${ids}.faa"
    else
        echo "Warning: no .faa found for $ref"
    fi

done < "$input_file"

echo "Done."

