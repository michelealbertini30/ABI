# Evolution of Gene Family ABI
**In collaboration with the Stoffwechselbiochemie Haass Lab of Ludwig-Maximilians-Universität-München**

---

In order to obtain an initial protein dataset:
```
../interproscan-5.65-97.0/interproscan.sh -i UniProt_ABI.raw.fa -f tsv -b ABI.tsv

sed 's/\s.*$//' UniProt_ABI.raw.fa > Uniprot_ABI.reformat.raw.fa

grep "SH3" ABI.tsv | awk '{print $1}' | sort -u > True_ABI.txt
grep "ABL" ABI.tsv | awk '{print $1}' | sort -u >> True_ABI.txt

bash Interpro.filter.sh Uniprot_ABI.reformat.raw.fa True_ABI.txt
```
