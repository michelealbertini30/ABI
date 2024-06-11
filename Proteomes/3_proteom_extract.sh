#!/bin/bash

mkdir -p Proteoms

while read line;
        do

        if echo $line | grep -qv "#";
                then

                ref=$(echo $line | awk '{print $1}')
                ids=$(echo $line | awk '{print $4}')

                cp $ref/ncbi_dataset/data/$ref/*.faa Proteoms/"$ids.faa"
        fi

done < $1
