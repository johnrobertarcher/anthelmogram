#!/bin/bash
### annotate beta-tubulin isotype-1 codon mutations using SnpEff
set -euo pipefail
shopt -s nullglob

# input
SNPEFF_JAR="/Users/john.archer/ls/share/snpeff-5.4.0c-0/snpEff.jar"
SNPEFF_CONFIG="/Users/john.archer/ls/share/snpeff-5.4.0c-0/snpEff.config"
SNPEFF_DATA="/Users/john.archer/ls/share/snpeff-5.4.0c-0/data"
GENOME="beta_tubulin_isotype_1"
REF_FASTA="" ### <- */reference_databases/beta_tubulin_isotype-1/reference_directory/beta_tub_iso-1_consensus_sequences_RA_2019.fasta
GFF3="" ### <- /Users/john.archer/Documents/Glasgow/anthelmogram/scripts/reference_databases/beta_tubulin_isotype-1/beta_tubulin_isotype_1.gff3
VCF_DIR="" ### <- */VarDict_VCF

# output
OUT_DIR="" ### <- */SnpEff_output

# setup
mkdir -p "$OUT_DIR"

### check required files exist
[ -f "$SNPEFF_JAR" ] || { echo "error: snpEff.jar not found"; exit 1; }
[ -f "$SNPEFF_CONFIG" ] || { echo "error: snpEff.config not found"; exit 1; }
[ -f "$REF_FASTA" ] || { echo "error: reference fasta not found"; exit 1; }
[ -f "$GFF3" ] || { echo "error: gff3 file not found"; exit 1; }

### check if SnpEff database exists
if [ ! -f "$SNPEFF_DATA/$GENOME/snpEffectPredictor.bin" ]; then

    echo "SnpEff database not found"
    echo "preparing genome folder"

    rm -rf "$SNPEFF_DATA/$GENOME"
    mkdir -p "$SNPEFF_DATA/$GENOME"

    cp "$GFF3" "$SNPEFF_DATA/$GENOME/genes.gff"
    cp "$REF_FASTA" "$SNPEFF_DATA/$GENOME/sequences.fa"

    # build SnpEff database
    echo "building SnpEff database"

    java -jar "$SNPEFF_JAR" build \
      -gff3 \
      -v \
      -c "$SNPEFF_CONFIG" \
      -dataDir "$SNPEFF_DATA" \
      -noCheckCds \
      -noCheckProtein \
      "$GENOME"

else

    echo "SnpEff database found"
    echo "skipping database build"

fi



### annotate VCFs
echo "annotating VCFs"

VCFS=("$VCF_DIR"/*.vcf)

echo "found ${#VCFS[@]} VCF files"

# SnpEff loop
for vcf in "${VCFS[@]}"
do

    sample=$(basename "$vcf" .vcf)

    echo "annotating: $sample"

    java -jar "$SNPEFF_JAR" ann \
      -v \
      -c "$SNPEFF_CONFIG" \
      -dataDir "$SNPEFF_DATA" \
      -stats "$OUT_DIR/${sample}.html" \
      "$GENOME" \
      "$vcf" \
      > "$OUT_DIR/${sample}.snpeff.vcf"

done

echo "vardict_SnpEff.sh complete"