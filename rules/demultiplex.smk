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