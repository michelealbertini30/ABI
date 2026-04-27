#!bin/bash
genomes=$1

if [ ! -d "$genomes" ]; then
	echo "Error: Folder '$genomes' not found."
	exit 1
fi

for file in $genomes/*.fna; do
	if [ ! -e "{$file%.fna}.busco" ]; then
		busco -i "$file" -m geno --cpu 15 -l metazoa_odb10 -o "${file%.fna}.busco"
	else
		continue
	fi
done
