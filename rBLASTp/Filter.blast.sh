#!/bin/bash

for i in *.txt; do
	output_file="$(basename "$i" .txt).besthit"

	awk '{print $1}' "$i" | sort -u | while read line; do
	grep "$line" "$i" | head -n1 >> "$output_file"
	done
done

