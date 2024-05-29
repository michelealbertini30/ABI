#!/bin/bash

ref=$(awk '{print $1}' $1 | grep -v "#" | tr "\n" " ")
ref=${ref%?}

for rf in $ref
do
	unzip $rf -d $rf
	if [ -d "$rf" ]; then
		rm $rf.zip
	fi
done
