#!/bin/bash

dir=$1

for file in "$dir"/*abi; do
	base=$(basename "$file" .rblastp.abi)
	col1=$(cut -f1 "$file")
	col2=$(cut -f2,3,4 "$base".crd)
	col3=$(cut -f2,3,4,5,6,7,8,9,10,11,12 "$file")

	paste <(printf %s "$col1") <(printf %s "$col2") <(printf %s "$col3")> "$base".final

done
