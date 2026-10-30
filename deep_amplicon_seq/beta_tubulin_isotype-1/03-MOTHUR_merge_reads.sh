#!/bin/bash
### merge cutadapt'ed paired-end reads using MOTHUR make.contigs
set -euo pipefail

# input illumina run-specific stability file
FILELIST="" ### <- generate_stability_file.sh output path: */AHG_illumina_*_stability_file

# output
OUT_DIR="" ### <- */AHG_illumina_*_merged_reads

# setup
mkdir -p "$OUT_DIR"
cd "$OUT_DIR"
THREADS=8

# MOTHUR make.contigs
mothur "#make.contigs(file=$FILELIST, processors=$THREADS)"

echo "MOTHUR_merge_reads.sh complete"

# output file names: 
# */AHG_illumina_*_stability_filetrim.contigs.fasta
# */AHG_illumina_*_stability_filescrap.contigs.fasta
# */AHG_illumina_*_stability_filecontigs_report
# */AHG_illumina_*_stability_filecontigs.count_table