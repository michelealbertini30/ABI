#!/bin/bash

file=$1
output=$2

declare -a loci_start
declare -a loci_end
declare -a loci_name
locus_counter=0

while read -r line; do
    # Extract gene name, start and end coordinates
    gene=$(echo "$line" | awk '{print $1}')
    start=$(echo "$line" | awk '{print $3}')
    end=$(echo "$line" | awk '{print $4}')

    overlaps=0

    # Check for overlap with existing loci
    for i in "${!loci_start[@]}"; do
        if (( end >= loci_start[i] && start <= loci_end[i] )); then
            # Yes Overlap
            overlaps=1
            echo -e "$gene\t${loci_name[i]}" >> "$output"
            break
        fi
    done

    # No overlap, create new locus
    if (( overlaps == 0 )); then
        locus_counter=$((locus_counter + 1))
        loci_start+=($start)
        loci_end+=($end)
        loci_name+=("locus$locus_counter")
        echo -e "$gene\tlocus$locus_counter" >> "$output"
    fi

done < "$file"
