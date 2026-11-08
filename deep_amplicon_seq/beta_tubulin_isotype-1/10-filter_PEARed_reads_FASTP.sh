#!/bin/bash
### filter PEAR-ed fastq files using FASTP: filters out any sample < 200 bp and > 450 bp, and any sequence with > ~1% ambiguous bases
set -euo pipefail

# input directory (PEAR output)
INPUT_DIR="" ### <- */AHG_illumina_*_PEAR_output

# output
OUTPUT_DIR="" ### <- */AHG_illumina_*_PEARed_FASTP_filtered
REPORT_DIR="" ### <- */AHG_illumina_*_FASTP_reports

# setup
mkdir -p "$OUTPUT_DIR"
mkdir -p "$REPORT_DIR"
echo -e "Sample\tRetained_Reads" > filtering_summary.tsv

# loop fastp
for f in "$INPUT_DIR"/*.assembled.fastq; do

    sample=$(basename "$f" .assembled.fastq)

    out_fastq="$OUTPUT_DIR/${sample}.filtered.fastq"
    json_report="$REPORT_DIR/${sample}.fastp.json"
    html_report="$REPORT_DIR/${sample}.fastp.html"

    fastp \
        -i "$f" \
        -o "$out_fastq" \
        --length_required 200 \
        --length_limit 450 \
        --n_base_limit 3 \
        --disable_adapter_trimming \
        --thread 8 \
        --json "$json_report" \
        --html "$html_report" \
        2> "$REPORT_DIR/${sample}.fastp.log"

    if [[ $? -ne 0 ]]; then
        echo "fastp failed for $sample" >&2
        continue
    fi

    if [[ -f "$json_report" ]]; then
        kept=$(jq '.summary.after_filtering.total_reads' "$json_report")
    else
        echo "warning: missing json for $sample" >&2
        kept="NA"
    fi

    echo -e "${sample}\t${kept}" >> filtering_summary.tsv

done

echo "filter_PEARed_reads_FASTP.sh done"