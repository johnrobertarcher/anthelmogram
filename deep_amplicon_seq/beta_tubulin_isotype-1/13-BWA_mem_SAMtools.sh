#!/bin/bash
### align formatted FASTQ files to respective susceptible reference sequence [beta_tub_iso-1_consensus_sequences_RA_2019.fasta] using BWA-MEM, convert SAM to BAM using SAMtools, and sort/index using SAMtools 
# NOTE: takes ~ 30 mins
set -euo pipefail

# input fastq directory (generated during [12-AHG_beta_tub_1_SPECIES_FASTQ.Rmd])
FASTQ_DIR="" ### <- */species_specific_FASTQ

# input reference database
REF="" ### <- */reference_databases/beta_tubulin_isotype-1/reference_directory/beta_tub_iso-1_consensus_sequences_RA_2019.fasta

# output
OUT_DIR="" ### <- */BWA_alignments

# setup
mkdir -p "$OUT_DIR"

# create reference index, if not already made
if [ ! -f "${REF}.bwt" ]; then
    bwa index "$REF"
fi

# list of allowed species (all species in reference FASTA are listed, but only species present in ITS2 data allowed)
# NOTE: excludes genus-level assignments
ALLOWED=(
"Cooperia_oncophora"
"Haemonchus_contortus"
"Nematodirus_helvetianus"
"Ostertagia_ostertagi"
"Teladorsagia_circumcincta"
"Trichostrongylus_colubriformis"
# "Cooperia_curticei"
# "Cooperia_pectinata"
# "Cooperia_punctata"
# "Haemonchus_placei"
# "Haemonchus_similis"
# "Nematodirus_battus"
# "Trichostrongylus_axei"
# "Trichostrongylus_vitrinus"
)



# loop over FASTQ files
for fq in "$FASTQ_DIR"/*.fastq
do
    base=$(basename "$fq" .fastq)

    # skip genus-level
    if [[ "$base" == *"_sp"* ]]; then
        echo "skipping genus-level file: $base"
        continue
    fi

    match=0
    for sp in "${ALLOWED[@]}"
    do
        if [[ "$base" == *"$sp"* ]]; then
            match=1
            species="$sp"
            break
        fi
    done

    if [[ $match -eq 0 ]]; then
        echo "skipping unknown species: $base"
        continue
    fi



    echo "processing $species ($base)"
    # BWA-MEM alignment
    bwa mem "$REF" "$fq" | \

        # samtools view: convert SAM to BAM
        samtools view -b - | \

        # samtools sort
        samtools sort -o "${OUT_DIR}/${base}.sorted.bam"

    # samtools index
    samtools index "${OUT_DIR}/${base}.sorted.bam"

done

echo "BWA.sh complete"