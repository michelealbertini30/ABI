# Evolution of ABI Gene Family
**In collaboration with the Stoffwechselbiochemie Haass Lab of Ludwig-Maximilians-Universität-München**

This project aims to study the evolution of ABI proteins in all Metazoans with particular focus on its evolution among Vertebrates.

---

## Table of contents
1. [About the project](#about)
2. [Genome download](#genome)
4. [Protein dataset](#protein)
3. [Bioinformatic Tools](#tools)

## <a name="about"></a> About the project
The ABI gene family includes Abi1, Abi2 and Abi3. They are SH3 domain-containing proteins that are involved in regulation of actin organisation. Abi1, Abi2 and Abi3 all participate in the formation of the Abi/WAVE complex, which regulates Arp2/3-mediated actin filament nucleation and actin network assembly.

## <a name="genome"></a> Genome download
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

## <a name="protein"></a> Protein dataset
Next, a [protein database](https://github.com/michelealbertini30/ABI/blob/main/Proteins/ABI.all_proteins.faa) was created from [UniProt](https://www.uniprot.org/) with all the annotated ABI genes in Metazoans. All downloaded proteins were filtered by domain:
```
../interproscan-5.65-97.0/interproscan.sh -i UniProt_ABI.raw.fa -f tsv -b ABI.tsv

sed 's/\s.*$//' UniProt_ABI.raw.fa > Uniprot_ABI.reformat.raw.fa

grep "ABI" ABI.tsv | awk '{print $1}' | sort -u > True_ABI_raw.txt
grep "Abl" ABI.tsv | awk '{print $1}' | sort -u >> True_ABI_raw.txt
sort -u True_ABI_raw.txt > True_ABI.txt

bash Interpro.filter.sh UniProt_ABI.raw.fa True_ABI.txt
```

The dataset was then expanded with ABI proteins from all available proteoms of the selected species:

```
for i in *.faa; do awk '/ABI |abl / {{print $1}}' "$i" | sed 's/>//g' | sort -u > "$(basename "$i" .faa).trueABI.txt"; done

for i in *.faa; do sed -E 's/^(>[^ ]+).*/\1/' $i > $i.reformat; done

bash Protein.filter.sh

for i in *filtered.fa; do awk -v basename="$(basename "$i" .filtered.fa)" '/^>/ {print $0 "|" basename; next}1' "$i" > $(basename "$i" .filtered.fa).abi; done

cat UniProt_ABI.raw.fa *.abi >> ABI.all_proteins.faa

```

## <a name="tools"></a> Bioinformatic pipeline for gene mining
Here is a complete list of all major softwares used in the main snakemake [X-Tract](https://github.com/michelealbertini30/ABI/blob/main/XTract.ABI.smk) pipeline:

* [Miniprot](https://github.com/lh3/miniprot)\
Miniprot aligns a protein sequence against a genome with affine gap penalty, splicing and frameshift. It is primarily intended for annotating protein-coding genes in a new species using known genes from other species.

* [Busco](https://busco.ezlab.org/)\
**B**enchmarking **U**niversal **S**ingle-**C**opy **O**rthologs: provides measures for quantitative assessment of genome assembly  completeness based on evolutionarily informed expectations.

* [Agat](https://github.com/NBISweden/AGAT)\
**A**nother **G**tf/**G**ff **A**nalysis **T**oolkit: Suite of tools to handle gene annotation in any GTF/GFF format.

* [Augustus](https://github.com/Gaius-Augustus/Augustus)\
Gene prediction program used as an ab initio predictor but can also incorporate hints on the gene structure from extrinsic sources.

* [Interproscan](https://github.com/ebi-pf-team/interproscan)\
Database that integrates predictive information about protein function, gene family belonging, and contained domains.

* [Modeltest-ng](https://github.com/ddarriba/modeltest)\
Tool for selecting the best-fit model of DNA or Protein evolution.

* [RAxML-ng](https://github.com/amkozlov/raxml-ng)\
Phylogenetic tree inference tool which uses a Maximum Likelihood optimality criterion.

* [GeneRax](https://github.com/BenoitMorel/GeneRax)\
Parallel tool for species tree-aware maximum likelihood based gene family tree inference under gene duplication, transfer and loss.

\
Throught the entire project we chose to use [Snakemake](https://snakemake.github.io/) as primary scripting method in order to make the code more efficient when running computationally heavy analysis and ensuring an easy way to introduce new genomes or protein samples without having to re-run the entire analysis.

To setup snakemake:
```
conda create -n snake-env
conda activate snake-env
mamba install -c bioconda snakemake
```
To run a snakefile:
```
snakemake --cores 1 --snakefile snakefile.smk
```
