#!/bin/bash
### use PICARD TOOLS to add header and sample information back to BAM files (lost during BAM processing) and re-index
set -euo pipefail

# input BWA alignments
BAM_DIR="" ### <- */BWA_alignments

# output
OUT_DIR="" ### <- */PICKARD_output

# setup
mkdir -p "$OUT_DIR"

# loop over all BAM files
for bam in "$BAM_DIR"/*.sorted.bam
do
    base=$(basename "$bam" .sorted.bam)

    echo "processing $base"

    # pickard AddOrReplaceReadGroups
    picard AddOrReplaceReadGroups \
        I="$bam" \
        O="${OUT_DIR}/${base}.RG.bam" \
        RGID="$base" \
        RGLB="beta_tub_amplicon" \
        RGPL="ILLUMINA" \
        RGPU="run1" \
        RGSM="$base"

    # samtools index to re-index BAM files
    samtools index "${OUT_DIR}/${base}.RG.bam"

done

echo "PICKARD_read_groups.sh complete"