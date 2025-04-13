#prank -d=ABI*.fna -o=ABI*.prank.aln -codon

# didn't do it #  bmge -i ABI*.prank.aln -t CODON -o ABI3.prank.bmge.aln
# didn't do it # trimal -in ABI1.prank.aln -out ABI1.prank.trimal.aln -resoverlap 0.8 -seqoverlap 80

iqtree -s ABI*.prank.aln -m MIX+MFP -asr 

hyphy meme --alignment ABI*.prank.aln --tree ABI*.prank.aln.treefile > meme.out

python hyphy_summary.py ABI*/raw/ --output_csv ABI*.csv

ResultsComparative selection analyses revealed marked differences in the evolutionary dynamics of ABI1, ABI2, and ABI3. 
While ABI2 appears highly conserved, with strong evidence of pervasive purifying selection and minimal adaptive changes, 
both ABI1 and especially ABI3 exhibit signatures of episodic positive selection affecting specific sites and lineages. 
Notably, ABI3 showed the strongest signal of adaptive evolution, consistent with recent functional diversification or 
lineage-specific selective pressures.

