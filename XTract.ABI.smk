configfile: 'logs/config.smk.yaml'
exp=config['Run']['Expansion']

getAnnoFasta=config['Scripts']['getAnnoFasta']

sample = glob_wildcards('Genomes/{sample}.fna')[0]


rule all:
	input:
		expand('miniprot_gff/{sample}.gff', sample = sample),
		expand('fai/{sample}.fai', sample = sample),
		expand('agat_cds/{sample}.agat.fa', sample = sample),
		expand('augustus/{sample}.augustus.gff', sample = sample),
		expand('augustus/{sample}.augustus.aa', sample = sample),
		expand('augustus/{sample}.augustus.codingseq', sample = sample),
		expand('interproscan/tsv/{sample}.augustus.aa.tsv', sample = sample),
#		expand('interproscan/gff/{sample}.augustus.aa.gff3', sample = sample),
#		expand('Genes/{sample}.filtered.fa', sample = sample),
		expand('Genes/{sample}.trueABI.txt', sample = sample),
#		expand('Genes/{sample}.filtered.reformat.fa', sample = sample),
#		expand('Genes/{sample}.cdhit.fa', sample = sample),
#		expand('Mafft/{sample}.mafft.fa', sample = sample),
#		'logs/augustus_statistics.log'
				

rule miniprot:
        input:
                genome = 'Genomes/{sample}.fna',
                proteins = 'Proteins/ABI.all_proteins.faa'
        threads:
                config['Run']['Threads']
        output:
                'miniprot_gff/{sample}.gff'
        shell:
                'miniprot -M0 -k5 --gff {input.genome} {input.proteins} > {output}'

rule agat:
	input:
		genome = 'Genomes/{sample}.fna',
		gff = 'miniprot_gff/{sample}.gff'
	output:
		agat = 'agat_cds/{sample}.agat.fa'
	shell:
		'agat_sp_extract_sequences.pl -g {input.gff} -f {input.genome} -t cds --up {exp} --down {exp} -o {output.agat}'		

rule augustus:
        input:
                fasta = 'agat_cds/{sample}.agat.fa'
        output:
                'augustus/{sample}.augustus.gff'
        shell:
                'augustus --species=metazoa --protein=on --codingseq=on --genemodel=complete {input.fasta} > {output}'

rule augustus_statistics:
        input:
                augustus_hits = expand('augustus/{sample}.augustus.gff', sample = sample)
        output:
                'logs/augustus_statistics.log'
	shell:
		'''
		echo -e "File\t\tN.hits\t\tUnique" > {output}

		for file in {input.augustus_hits}; do
			if [ -e "$file" ]; then
				filename=$(basename "$file" .augustus.gff)

				result1=$(grep -c "start gene" "$file")
				result2=$(grep -A 1 "start gene" "$file" | awk '/MP/ {{print $1}}' | sort -u | wc -l)

				echo -e "$filename\t\t$result1\t\t$result2" >> {output}
			fi
		done

		'''

rule augustus_extract:
	input:
		augustus_hits = rules.augustus.output
	output:
		aa = 'augustus/{sample}.augustus.aa',
		codingseq = 'augustus/{sample}.augustus.codingseq'
	shell:
		'''
		perl {getAnnoFasta} {input.augustus_hits} | tee {output.aa}
		'''

rule interproscan_tsv:
	input:
		augustus_aa = 'augustus/{sample}.augustus.aa'
	output:
		interpro = 'interproscan/tsv/{sample}.augustus.aa.tsv'
	shell:
		'''
		/home/STUDENTI/michele.albertini/Interproscan/interproscan-5.67-99.0/interproscan.sh -i {input.augustus_aa} -f tsv -o {output.interpro}
		'''

rule interproscan_gff:
        input:
                augustus_aa = 'augustus/{sample}.augustus.aa'
        output:
                interpro = 'interproscan/gff/{sample}.augustus.aa.gff3'
        shell:
                '''
                /home/STUDENTI/michele.albertini/Interproscan/interproscan-5.67-99.0/interproscan.sh -i {input.augustus_aa} -f gff3 -o {output.interpro}
                '''

rule interpro_filter1:
	input:
		interpro = 'interproscan/tsv/{sample}.augustus.aa.tsv'
	output:
		trueABI = 'Genes/{sample}.trueABI.txt'
	shell:
		'''
		for file in {input.interpro}; do
			if [ -e "$file" ]; then

				result=$(awk '/ABI|Abl|abl|Abi/ {{print $1}}' "$file" | sort -u)
				echo -e "$result" > {output.trueABI}

			fi
		done		
		'''

rule interpro_filter2:
        input:
                fasta = 'augustus/{sample}.augustus.aa',
                txt = 'Genes/{sample}.trueABI.txt'
        output:
                'Genes/{sample}.filtered.fa'
        shell:
                'bash Scripts/Interpro_filter_smk.sh {input.fasta} {input.txt} {output}'

rule reformat_combine:
	input:
		genes = 'Genes/{sample}.filtered.fa'
	output:
		reformat = 'Genes/{sample}.filtered.reformat.fa'
	shell:
		'''
		for file in {input.genes}; do
			filename=$(basename "$file" .filtered.fa)

			sed "s/t1/$filename/g" {input.genes} > {output.reformat}

               done

		'''
rule cdhit:
        input:
                genes = 'Genes/{sample}.filtered.reformat.fa'
        output:
                'Genes/{sample}.cdhit.fa'
        shell:
                'cd-hit -i {input.genes} -c 1.00 -o {output}'



rule mafft:
	input:
		genes = 'Genes/{sample}.filtered.reformat.fa'
	output:
		aligned = 'Mafft/{sample}.mafft.fa'
	shell:
		'mafft {input.genes} > {output.aligned}'
