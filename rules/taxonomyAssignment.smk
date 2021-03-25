rule taxonomyAssignment:
	input:
		WORKFLOW_DATA + "/vsearch_fixed_{barcode}.txt"
	output:
		merged=WORKFLOW_DATA + "/merged_fixed_{barcode}.fasta",
		taxonomy=OUTPUT_DIR + "/03_LCPs_peaks/01_taxonomic_assignments/taxonomy_{barcode}.txt"
	params:
		consensus=OUTPUT_DIR + "/03_LCPs_peaks/00_peak_consensus",
		taxonomy=OUTPUT_DIR + "/03_LCPs_peaks/01_taxonomic_assignments", 
		taxonomy_final=OUTPUT_DIR + "/03_LCPs_peaks/01_taxonomic_assignments/taxonomy_assignments.txt"
	threads: config["threads_kraken"]
	shell:
		"""
		mkdir -p {params.taxonomy}
		cat {input} | while read line
		do
			echo "{params.consensus}/$line.fasta"
			if [ -s {params.consensus}/$line.fasta ]
			then
				cat {params.consensus}/$line.fasta >> {output.merged}
			fi
		done
		kraken2 --db {config[kraken_db]} --threads {threads} {output.merged} --use-names > {output.taxonomy} || true 
		touch {output.taxonomy}
		touch {output.merged}
		awk -F '\t' '{{print FILENAME " " $3}}' {output.taxonomy} | sort | uniq -c | sort -nr >> {params.taxonomy_final} 
		"""

def aggregate_input2(wildcards):
    checkpoint_output = checkpoints.demultiplexing_1.get(**wildcards).output[0]
    return expand(OUTPUT_DIR + "/03_LCPs_peaks/01_taxonomic_assignments/taxonomy_{barcode}.txt",
           barcode = glob_wildcards(checkpoint_output + "/{barcode, repBC[0-9]+}").barcode)

rule checkOutputs:
	input:
		#expand(OUTPUT_DIR + "/03_LCPs_peaks/01_taxonomic_assignments/taxonomy_{barcode}.txt", barcode=BARCODES)
	    aggregate_input2
	output:
		protected(OUTPUT_DIR + "/check.txt")
	params:
		peaks=OUTPUT_DIR + "/03_LCPs_peaks"
	shell:
		"""
		rm {params.peaks}/*fastq {params.peaks}/*fasta 
		echo "On-rep-seq succesfuly executed" >> {output}
		"""

