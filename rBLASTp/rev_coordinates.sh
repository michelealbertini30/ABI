#!/bin/bash

file=$1

while read line; do
	base=$(basename "$file" .rblastp.abi)
	MP=$(grep -w "$line" ../augustus/"$base".augustus.gff | grep -v "#" | cut -f1 | sort -u)
	crd=$(grep "$MP" ../miniprot_gff/"$base".gff | grep "mRNA" | cut -f 3,4,5)
	paste <(printf %s "$line") <(printf %s "$crd") >> output
done < <(cut -f1 "$file" | awk -F "." '{print $1}')

