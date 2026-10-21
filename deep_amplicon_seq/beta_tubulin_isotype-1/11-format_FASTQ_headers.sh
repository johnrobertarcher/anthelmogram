#!/bin/bash
### format PEAR-ed and filtered FASTQ headers to match headers in kNN file (i.e., replace colons with underscores)
set -euo pipefail
shopt -s nullglob

# input fastp filtered fastq files
INPUT_DIR="" ### <- */PEARed_FASTP_filtered

# output
OUTPUT_DIR="" ### <- */PEARed_FASTP_filtered_FORMATTED

# setup
mkdir -p "$OUTPUT_DIR"

# loop over fastq files
for fq in "$INPUT_DIR"/*.fastq; do

    out="$OUTPUT_DIR/$(basename "$fq")"

    awk '
    NR % 4 == 1 {

        # remove @
        sub(/^@/, "", $0)

        # keep only first token (drop everything after space)
        split($0, a, " ")
        id = a[1]

        # convert colons to underscores
        gsub(":", "_", id)

        # re-add FASTQ header marker
        print "@" id
        next
    }

    { print }

    ' "$fq" > "$out"

    echo "processed: $(basename "$fq")"

done

echo "format_FASTQ_headers.sh done"