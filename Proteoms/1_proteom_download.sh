#!/bin/bash

ref=$(awk '{print $1}' $1 | grep -v "#" | tr "\n" " ")
ref=${ref%?}

for rf in $ref
	do
		datasets download genome accession $rf --include protein --filename $rf.zip
	done
