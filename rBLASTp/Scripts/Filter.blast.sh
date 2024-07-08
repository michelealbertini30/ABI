#!/bin/bash

file=$1
output=$2

awk '{print $1}' "$file" | sort -u | while read line; do
	grep "$line" "$file" | head -n1 >> "$output"
done

