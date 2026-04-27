#!/bin/bash

directory=$1

for file in "$directory"/*.faa; do
	if [ -e "$file" ]; then
		final_file=$(basename "$file" .faa).trueABI.txt
		result=$(grep -e "ABI " -e "abl " "$file" | awk -F "[" '{print $1}' | sed 's/>//g' | sed 's/ /_/g')
		echo -e "$result" > "$directory"/"$final_file"
		echo "$final_file created"
	fi
done
