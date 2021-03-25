shell.executable("/bin/bash")

import os
import re
#======================================================
# Config files
#======================================================
configfile: "config.yaml"
wildcard_constraints:
        barcode="repBC[0-9]+"

#======================================================
# Global variables
#======================================================
RULES_DIR = 'rules'
BASECALLED_DIR = config["basecalled_dir"]
INPUT_DIR=config["basecalled_dir"].rstrip("/")
OUTPUT_DIR=config["results_dir"].rstrip("/")
WORKFLOW_DATA=OUTPUT_DIR + "/ON-rep-seq_DATA"

with open("scripts/logo.txt") as f:
    print(f.read())

#======================================================
# Rules
#======================================================

rule all:
    input:
        OUTPUT_DIR + "/02_LCPs/LCP_plots.pdf",
        OUTPUT_DIR + "/02_LCPs/LCP_clustering_heatmaps.html",
        OUTPUT_DIR + "/02_LCPs/LCP_clustering_heatmaps.ipynb",
        OUTPUT_DIR + "/check.txt"

include: os.path.join(RULES_DIR, 'demultiplex.smk')
include: os.path.join(RULES_DIR, 'LCPs.smk')
include: os.path.join(RULES_DIR, 'peakCorrection.smk')
include: os.path.join(RULES_DIR, 'taxonomyAssignment.smk')
