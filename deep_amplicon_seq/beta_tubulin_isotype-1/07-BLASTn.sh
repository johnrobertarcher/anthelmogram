#!/bin/bash
### use generated [*/AHG_illumina_*_KEPT_SEQUENCES.fasta] to perform BLASTn. 
# NOTE: returns top three hits only (kNN = 3); takes ~ 2 hours (8 threads)
set -euo pipefail

# input query fasta: */AHG_illumina_*_KEPT_SEQUENCES.fasta
QUERY_FASTA="" ### <- */AHG_illumina_*_KEPT_SEQUENCES.fasta

# input reference databse fasta: beta_tub_iso-1_sequence_database_JA_2026_FULL_GENUS_SPECIES_IN_HEADERS.fasta
REF_FASTA="" ### <- */reference_databases/beta_tub_iso-1_sequence_database_JA_2026_FULL_GENUS_SPECIES_IN_HEADERS.fasta"

# input BLASTn database generated here: beta_tubulin_isotype-1/beta_tub_iso-1_BLASTn_database
DB="" ### <- */reference_sequence_databases/beta_tub_iso-1_BLASTn_database

# output
BLAST_OUT="" ### <- */AHG_illumina_*_BLASTn_output.tsv

# setup
mkdir -p "$(dirname "$BLAST_OUT")"

# build BLASTn database from reference FASTA if does not already exist
if [[ ! -f "${DB}.nhr" ]]; then

    echo "building BLASTn database"

    makeblastdb \
        -in "$REF_FASTA" \
        -dbtype nucl \
        -out "$DB" \
        -title "beta_tubulin_database"

    echo "BLASTn database created: $DB"

else

    echo "BLASTn database already exists: $DB"

fi

# BLASTn. NOTE: top three hits returned only (kNN = 3); takes ~ 2 hours (8 threads)
echo "running BLASTn"

blastn \
    -query "$QUERY_FASTA" \
    -db "$DB" \
    -task megablast \
    -outfmt "6 qseqid sseqid pident length bitscore" \
    -max_target_seqs 3 \
    -max_hsps 1 \
    -num_threads 8 \
    -out "$BLAST_OUT"

echo "BLASTn.sh complete"