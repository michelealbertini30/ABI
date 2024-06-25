configfile: 'log/RevBLAST.config.yml'
blast_db=config['Files']['Blast_Database']

sample = glob_wildcards('Genes/{sample}.cdhit.fa')[0]


rule all:
        input:
                expand('blast/{sample}.rblastp.txt', sample = sample),
		expand('blast/{sample}.top', sample = sample),

rule reverse_blast:
        input:
                'Genes/{sample}.cdhit.fa'
        output:
                'blast/{sample}.rblastp.txt'
        shell:
                'blastp -query {input} -db {blast_db} -outfmt 6 -out {output}'


rule best_hit:
	input:
		'blast/{sample}.rblastp.txt'
	output:
		'blast/{sample}.top'
	shell:
		'shell Scripts/Filter.blast.sh {input} {output}'








#rule mafft:
 #       input:
  #              genes = 'Genes/{sample}.filtered.reformat.fa'
   #     output:
    #            aligned = 'Mafft/{sample}.mafft.fa'
     #   shell:
      #          'mafft {input.genes} > {output.aligned}'
