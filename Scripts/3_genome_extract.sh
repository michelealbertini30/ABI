#!/bin/bash

mkdir -p Genomes

while read line;
        do

        if echo $line | grep -qv "#";
                then

                ref=$(echo $line | awk '{print $1}')
                ids=$(echo $line | awk '{print $2}')

                cp $ref/ncbi_dataset/data/$ref/*.fna Genomes/"$ids.fna"
        fi

done < $1
