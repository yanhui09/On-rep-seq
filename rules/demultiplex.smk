#rule demultiplexing_1:
#    input:
#        BASECALLED_DIR
#    output:
#        temp(directory(OUTPUT_DIR + "/01_porechopped_data/{sample}/"))
#    params:
#        output_dir=OUTPUT_DIR + "/01_porechopped_data/{sample}"
#    conda:
#        "envs/On-rep-seq.yaml"
#    message:
#        "Demultiplexing step 1"
#    threads: 4
#    shell:
#        """
#        echo {wildcards.sample}
#        porechop -i {input}/{wildcards.sample}.fastq -b {params} -t {threads} --discard_unassigned --verbosity 2 > /dev/null 2>&1
#        line=$(echo {BARCODES})
#        for barcode in $line
#        do
#            touch {params}/$barcode.fastq
#        done
#        """
#
#rule merge_first_demultiplexing:
#    input:
#        (expand(OUTPUT_DIR + "/01_porechopped_data/{sample}/", sample=SAMPLES))
#    output:
#        temp(OUTPUT_DIR + "/01_porechopped_data/temporal_{barcode}.fastq")
#    params:
#        output_dir=OUTPUT_DIR + "/01_porechopped_data"
#    message:
#        "Merging barcodes"
#    threads: 2
#    shell:
#        """
#        cat {params}/*/{wildcards.barcode}.fastq > {output}
#        echo "{params}/*/{wildcards.barcode}.fastq > {output}"
#        """

#rule demultiplexing_2:
#    input:
#        OUTPUT_DIR + "/01_porechopped_data/temporal_{barcode}.fastq"
#    output:
#        OUTPUT_DIR + "/01_porechopped_data/{barcode}_demultiplexed.fastq"
#    params:
#        OUTPUT_DIR + "/01_porechopped_data/rejected_{barcode}.fastq"
#    conda:
#        "envs/On-rep-seq.yaml"
#    shell:
#        """
#        if [ -s {input} ]
#        then
#            porechop -i {input} -o {output} --fp2ndrun --verbosity 0
#            reads=$(grep -c "^@" {output})
#            if (( $reads < 2000 ))
#            then
#                mv {output} {params}
#                touch {output}
#            fi
#        else
#            touch {output}
#        fi
#        """

checkpoint demultiplexing_1:
    input:  
        BASECALLED_DIR
    output: 
        directory(OUTPUT_DIR + "/01_guppy_data/")
    threads: config["threads_guppy"]
    shell:
        """
        #if nvidia-smi; then
        #    {config[guppy_dir]}/guppy_barcoder -i {input} -s {output} -t {threads} --barcode_kits ONREPBC192 -x auto
        #else
        #    {config[guppy_dir]}/guppy_barcoder -i {input} -s {output} -t {threads} --barcode_kits ONREPBC192
        #fi

        {config[guppy_dir]}/guppy_barcoder -i {input} -s {output} -t {threads} --barcode_kits ONREPBC192
        """

rule demultiplexing_2:
    input:
        OUTPUT_DIR + "/01_guppy_data/{barcode}"
    output:
        OUTPUT_DIR + "/01_guppy_data/{barcode}_demultiplexed.fastq"
    params:
        rejected=OUTPUT_DIR + "/01_guppy_data/rejected_{barcode}.fastq",
        guppy_dir=OUTPUT_DIR + "/01_guppy_data"
    shell:
        """
        cat {input}/*.fastq > {output}
        cat {params.guppy_dir}/unclassified/*.fastq > {params.rejected}
        """