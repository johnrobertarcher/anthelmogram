#!/bin/bash
### call variants for each species (from each sample) using VarDict
# NOTE: uses curated beta-tubulin-isotype-1 amplicon BED file [vardict_BED_coordinates.bed]
# NOTE: use a minimum frequency of 0.1% and maximum allowed mismatches of 40 compared with reference sequences; stores raw .txt files in one folder and VCF files (converted from .txt files) in another
set -euo pipefail

# input reference fasta: */reference_databases/beta_tubulin_isotype-1/reference_directory/beta_tub_iso-1_consensus_sequences_RA_2019.fasta
REF="" ### <- */reference_databases/beta_tubulin_isotype-1/reference_directory/beta_tub_iso-1_consensus_sequences_RA_2019.fasta

# input BAM directory (PICKARD_read_groups.sh output)
BAM_DIR="" ### <- */PICKARD_output

# input curated beta-tubulin-isotype-1 amplicon BED file
BED="" ### <- */reference_sequence_databases/vardict_BED_coordinates.bed

# output folders
RAW_DIR="" ### <- */VarDict_raw
VCF_DIR="" ### <- */VarDict_VCF
LOG_DIR="" ### <- */VarDict_logs

# vardict helper scripts
VARDICT_SHARE="/Users/john.archer/ls/share/vardict-1.8.2-2"
TEST_STRAND="${VARDICT_SHARE}/teststrandbias.R"
VCF_CONVERT="${VARDICT_SHARE}/var2vcf_valid.pl"

# make output directories
mkdir -p "$RAW_DIR"
mkdir -p "$VCF_DIR"
mkdir -p "$LOG_DIR"

# index reference if needed
if [ ! -f "${REF}.fai" ]; then
    samtools faidx "$REF"
fi

# parameters
MIN_AF=0.001
MAX_MISMATCH=40

# check helper scripts exist
command -v vardict-java >/dev/null 2>&1 || { echo "error: vardict-java not found"; exit 1; }
[ -f "$TEST_STRAND" ] || { echo "error: teststrandbias.R not found"; exit 1; }
[ -f "$VCF_CONVERT" ] || { echo "error: var2vcf_valid.pl not found"; exit 1; }

# check BED exists
[ -f "$BED" ] || { echo "error: BED file not found"; exit 1; }

# create BAM list
shopt -s nullglob
BAMS=("$BAM_DIR"/*.bam)

echo "found ${#BAMS[@]} BAM files"



# vardict loop over BAM files
for bam in "${BAMS[@]}"
do
    sample=$(basename "$bam" .bam)

    echo "processing ${sample}"

    RAW_OUT="${RAW_DIR}/${sample}.raw.txt"
    VCF_OUT="${VCF_DIR}/${sample}.vcf"
    LOG_OUT="${LOG_DIR}/${sample}.log"

    # ensure BAM index exists
    if [ ! -f "${bam}.bai" ]; then
        samtools index "$bam"
    fi

    vardict-java \
        -G "$REF" \
        -N "$sample" \
        -b "$bam" \
        -f "$MIN_AF" \
        -m "$MAX_MISMATCH" \
        -c 1 -S 2 -E 3 -g 4 \
        "$BED" \
        >"$RAW_OUT" 2>"$LOG_OUT"

    if [[ ! -s "$RAW_OUT" ]]; then
        echo "warning: no variants reported for ${sample}" | tee -a "$LOG_OUT"
        continue
    fi

    "$TEST_STRAND" < "$RAW_OUT" \
        | perl "$VCF_CONVERT" \
            -N "$sample" \
            -E \
            -f "$MIN_AF" \
        >"$VCF_OUT" 2>>"$LOG_OUT"

done

echo "vardict.sh complete"