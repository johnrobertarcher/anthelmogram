#!/bin/bash
### join cutadapt’ed paired-end reads to form contigs using PEAR (minimum overlap: 10 bp)
set -euo pipefail

# input cutadapt'ed paired-end reads
INPUT_DIR="" ### <- cutadapt output filepath: */cutadapt_beta_tubulin_isotype-1

# output
OUTPUT_DIR="" ### <- */PEAR_output

# setup
mkdir -p "$OUTPUT_DIR"

# loop over R1 files
for R1 in "$INPUT_DIR"/*_R1_001.fastq.gz; do

    # extract sample ID
    SAMPLE=$(basename "$R1" | cut -d'_' -f1)

    # R2 files
    R2="$INPUT_DIR/${SAMPLE}_R2_001.fastq.gz"

    if [[ ! -f "$R2" ]]; then
        echo "warning: missing R2 for sample $SAMPLE"
        continue
    fi

    echo "processing sample: $SAMPLE"

    pear \
        -f "$R1" \
        -r "$R2" \
        -o "$OUTPUT_DIR/$SAMPLE" \
        -j 4 \
        -n 10

done

echo "PEAR.sh complete"