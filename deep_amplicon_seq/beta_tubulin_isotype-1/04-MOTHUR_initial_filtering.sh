#!/bin/bash
### filter and remove MOTHUR-merged reads if < 200 bp and > 450 bp in length, and if there are ambiguous bases in the contig overlapping region
set -euo pipefail

# input MOTHUR_merge_reads.sh output: */stability_filetrim.contigs.fasta and */stability_filecontigs.count_table
INPUT_DIR="" ### <- MOTHUR_merge_reads.sh output path
FASTA="$INPUT_DIR/" ### <- */AHG_illumina_*_stability_filetrim.contigs.fasta
COUNT="$INPUT_DIR/" ### <- */AHG_illumina_*_stability_filecontigs.count_table

# output
OUTPUT_DIR="" ### <- */AHG_illumina_*_MOTHUR_filtered

# setup
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# MOTHUR screen.seqs
mothur "#screen.seqs(fasta=$FASTA, count=$COUNT, minlength=200, maxlength=450, maxambig=0)"

echo "MOTHUR_filtering.sh complete"

# output file names:
# */AHG_illumina_*_stability_filetrim.contigs.good.fasta
# */AHG_illumina_*_stability_filetrim.contigs.bad.accnos
# */AHG_illumina_*_stability_filecontigs.good.count_table