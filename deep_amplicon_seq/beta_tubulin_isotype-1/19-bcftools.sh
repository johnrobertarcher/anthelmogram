#!/bin/bash
### use bcftools mpileup to count reads (all alleles: resistant and susceptible) at codons 28 (167), 59 (198) and 61 (200). 
# NOTE: uses curated [bcftools_BED_coordinates.bed] file
# NOTE: default is to limit to 250 reads --- that default is removed here, allowing all reads to be collated
# NOTE: then use bcftools call to convert .txt files to vcf
set -euo pipefail

# input BAM directory
BAM_DIR="" ### <- */PICKARD_output

# input reference fasta
REF="" ### <- */reference_sequence_databases/beta_tub_iso-1_consensus_sequences_JA_2026.fasta

# input curated [bcftools_BED_coordinates.bed] file
REGIONS="" ### <- */reference_sequence_databases/bcftools_BED_coordinates.bed

# output
OUT_DIR="" ### <- */bcftools_output

# setup
mkdir -p "$OUT_DIR"

# bcftools mpileup. NOTE: -a flag too keep all alleles at all sites... followed by bcftools call
for bam in "$BAM_DIR"/*.bam; do

    sample=$(basename "$bam" .bam)

   bcftools mpileup \
    -f "$REF" \
    -R "$REGIONS" \
    -a AD,DP \
    -d 0 \
    -Ou \
    "$bam" |
    bcftools view \
    -Oz \
    -o "$OUT_DIR/${sample}.vcf.gz"

    # index the VCF
    bcftools index "$OUT_DIR/${sample}.vcf.gz"

done

echo "bcftools.sh complete"