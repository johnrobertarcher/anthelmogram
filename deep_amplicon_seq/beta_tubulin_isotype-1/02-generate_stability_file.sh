#!/bin/bash
### generate stability file from cutadapt’ed reads to be used by MOTHUR
set -euo pipefail

# input cutadapt'ed paired-end reads
RAW_DIR="" ### <- cutadapt output filepath: */cutadapt_beta_tubulin_isotype-1

# output. NOTE: change stability file ID, depending on illumina run ID
OUTFILE="" ### <- */AHG_illumina_*_stability_file.txt

# remove previous version, if present
rm -f "$OUTFILE"

# loop over fastq files
for R1 in "$RAW_DIR"/*_R1_001.fastq.gz; do

    R2="${R1/_R1_/_R2_}"

    # check both files exist
    if [[ ! -f "$R2" ]]; then
        echo "warning: missing R2 for $R1" >&2
        continue
    fi

    SAMPLE=$(basename "$R1" | sed 's/_R1_001.fastq.gz//')

    printf "%s\t%s\t%s\n" "$SAMPLE" "$R1" "$R2" >> "$OUTFILE"

done

echo "generate_stability_file.sh complete"