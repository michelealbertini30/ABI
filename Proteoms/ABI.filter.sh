#!/bin/bash

directory=$1

for file in "$directory"/*.faa; do
	if [ -e "$file" ]; then
		final_file=$(basename "$file" .faa).txt
		result=$(grep -e "ABI " -e "abl " "$file" | awk '{print $1}' | sed 's/>//g')
		echo -e "$result" > "$directory"/"$final_file"
		echo "$final_file created"
	fi
done
