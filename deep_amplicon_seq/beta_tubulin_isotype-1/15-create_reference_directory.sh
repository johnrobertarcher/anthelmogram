#!/bin/bash
### create a reference sequence directory to be used for variant calling (VARDICT)
# NOTE: not needed for every illumina run
set -euo pipefail

# input reference FASTA
REF="" ### <- */reference_sequence_databases/beta_tub_iso-1_consensus_sequences_JA.fasta

# output directory
REF_DIR="" ### <- */reference_sequence_databases/reference_directory

# setup
mkdir -p "$REF_DIR"

# copy reference FASTA into new directory
REF_BASENAME=$(basename "$REF")
REF_COPY="${REF_DIR}/${REF_BASENAME}"
cp "$REF" "$REF_COPY"

# samtools index
samtools faidx "$REF_COPY"

# create sequence directory using PICKARD
DICT="${REF_COPY%.fasta}.dict"

picard CreateSequenceDictionary \
    R="$REF_COPY" \
    O="$DICT"

# create BWA index
bwa index "$REF_COPY"



# check outputs created successfully
echo "create_reference_directory.sh done - reference directory contents:"
ls -lh "$REF_DIR"
echo "generated files:"
echo "  FASTA  : $REF_COPY"
echo "  FAI    : ${REF_COPY}.fai"
echo "  DICT   : $DICT"
echo "  BWA    : .amb .ann .bwt .pac .sa"