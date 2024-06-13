#!/bin/bash

directory=$1

for file in "$directory"/*.abi; do

	while read line; do
		base=$(basename "$file" .rblastp.abi)
		MP=$(grep -w "$line" ../../augustus/"$base".augustus.gff | grep -v "#" | cut -f1 | sort -u)
		crd=$(grep "$MP" ../../miniprot_gff/"$base".gff | grep "mRNA" | cut -f 3,4,5)
		paste <(printf %s "$line") <(printf %s "$crd") >> "$base".crd

		echo -e "Coordinates extracted for $base.crd"

	done < <(cut -f1 "$file" | awk -F "." '{print $1}')
done
