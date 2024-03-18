# Evolution of Gene Family ABI
**In collaboration with the Stoffwechselbiochemie Haass Lab of Ludwig-Maximilians-Universität-München**

This project aims to study the evolution of ABI proteins in all Metazoans with particular focus on its evolution among Vertebrates.

---

## Table of contents
1. [About the project](#about)
2. [Setup and Genome download](#setup)
3. [Bioinformatic Tools](#tools)

## <a name="about"></a> About the project
The ABI gene family includes Abi1, Abi2 and Abi3. They are SH3 domain-containing proteins that are involved in regulation of actin organisation. Abi1, Abi2 and Abi3 all participate in the formation of the Abi/WAVE complex, which regulates Arp2/3-mediated actin filament nucleation and actin network assembly.

## <a name="setup"></a> Setup and Genome download
Genome selection was done considering all Metazoans refseq-genomes with chromosome level assembly. The species were selected based on the taxonomy by maximizing the spread and coverage of the metazoan phylogeny. When in doubt the genomes where selected based on the assembly quality.

All Metazoans Genomes selected were used to build the [genome dataset](https://github.com/michelealbertini30/ABI/blob/main/refSeq/ABI_Assembly_accession.tsv). All genomes were downloaded from [NCBI](https://www.ncbi.nlm.nih.gov/) using the following script:

```
mkdir Genomes
while read line;
        do

        if echo $line | grep -qv "#";
                then

                ref=$(echo $line | awk '{print $1}')
                ids=$(echo $line | awk '{print $2}')

                datasets download genome accession $rf --include genome --dehydrated --filename $rf.zip

                unzip $rf -d $rf
		datasets rehydrate --directory $rf

                cp $ref/ncbi_dataset/data/$ref/*.fna Genomes/$ids.fna
        fi

done < refseq_genomes.tsv
```
\
Next, a [protein database](https://github.com/michelealbertini30/Polyneoptera-P450/blob/main/UniProt_P450_RInsecta.fasta) was created on [UniProt](https://www.uniprot.org/) with all the annotated ABI genes in Metazoans.


In order to obtain an initial protein dataset, all proteins downloaded were filtered by domain:
```
../interproscan-5.65-97.0/interproscan.sh -i UniProt_ABI.raw.fa -f tsv -b ABI.tsv

sed 's/\s.*$//' UniProt_ABI.raw.fa > Uniprot_ABI.reformat.raw.fa

grep "SH3" ABI.tsv | awk '{print $1}' | sort -u > True_ABI_raw.txt
grep "ABL" ABI.tsv | awk '{print $1}' | sort -u >> True_ABI_raw.txt
sort -u True_ABI_raw.txt > True_ABI.txt

bash Interpro.filter.sh Uniprot_ABI.reformat.raw.fa True_ABI.txt
```
