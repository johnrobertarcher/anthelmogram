#!/bin/bash
### filter [*/AHG_illumina_*_stability_filetrim.contigs.good.align_report] to remove any sequences that do not align to at least 10% of any reference sequence with at least 60% similarity, and generate a new FASTA file containing only retained sequences
set -euo pipefail

# input MOTHUR_alignment.sh output: */AHG_illumina_*_stability_filetrim.contigs.good.align_report 
REPORT="" ### <- */AHG_illumina_*_stability_filetrim.contigs.good.align_report 

# input MOTHUR_initial_filtering.sh output: */AHG_illumina_*_stability_filetrim.contigs.good.fasta
FASTA="" ### <- */AHG_illumina_*_stability_filetrim.contigs.good.fasta

# output
OUTPUT_DIR="" ### <- */AHG_illumina_*_MOTHUR_aligned_filtered
PASSED_IDS="$OUTPUT_DIR/" ### <- AHG_illumina_*_KEPT_SEQUENCE_IDs.txt
FILTERED_FASTA="$OUTPUT_DIR/" ### <- AHG_illumina_*_KEPT_SEQUENCES.fasta

# setup
mkdir -p "$OUTPUT_DIR"

# extract passing sequence IDs
echo "filtering"

awk -F'\t' '
NR==1 {next}
{
    query = $1
    template_len = $4
    align_len = $12
    sim = $16

    if (template_len > 0) {
        cov = align_len / template_len
    } else {
        cov = 0
    }

    if (cov >= 0.10 && sim >= 60) {
        print query
    }
}
' "$REPORT" | sort -u > "$PASSED_IDS"



# MOTHUR get.seqs
mothur "#get.seqs(fasta=$FASTA, accnos=$PASSED_IDS)"
PICKED_FASTA="${FASTA%.fasta}.pick.fasta"

if [[ ! -f "$PICKED_FASTA" ]]; then
    echo "warning: mothur did not produce expected file"
    exit 1
fi

# move
mv "$PICKED_FASTA" "$FILTERED_FASTA"

echo "MOTHUR_alignment_filtering.sh done"

# output file names:
# */AHG_illumina_*_stability_filetrim.contigs.good.pick.fasta
# */AHG_illumina_*_KEPT_SEQUENCE_IDs.txt
# */AHG_illumina_*_KEPT_SEQUENCES.fasta