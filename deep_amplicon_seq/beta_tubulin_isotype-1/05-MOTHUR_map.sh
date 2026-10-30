#!/bin/bash
### align retained sequences to reference sequence database [beta_tub_iso-1_sequence_database_JA_2026_FULL_GENUS_SPECIES_IN_HEADERS.fasta] using MOTHUR align.seqs (default Needleman-wunsch algorithm)
# NOTE: output fasta is an alignment
set -euo pipefail

# input MOTHUR_initial_filtering.sh output: */stability_filetrim.contigs.good.fasta
INPUT_DIR="" ### <- MOTHUR_initial_filtering.sh output path
FASTA="$INPUT_DIR/" ### <- */AHG_illumina_*_stability_filetrim.contigs.good.fasta

# input reference database: 
REF="" ### <- */reference_databases/beta_tubulin_isotype-1/beta_tub_iso-1_sequence_database_JA_2026_FULL_GENUS_SPECIES_IN_HEADERS.fasta

# output
OUTPUT_DIR="" ### <- */MOTHUR_aligned

# setup
mkdir -p "$OUTPUT_DIR"

# MOTHUR align.seqs
mothur "#align.seqs(fasta=$FASTA, reference=$REF, outputdir=$OUTPUT_DIR, processors=8)"

echo "MOTHUR_alignment.sh complete"

# output file names: 
# */AHG_illumina_*_stability_filetrim.contigs.good.align
# */AHG_illumina_*_stability_filetrim.contigs.good.align_report
# */AHG_illumina_*_stability_filetrim.contigs.good.flip.accnos