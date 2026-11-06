#!/bin/bash
### build custom SnpEff database
set -euo pipefail

# input
SNPEFF_JAR="/Users/john.archer/ls/share/snpeff-5.4.0c-0/snpEff.jar"
SNPEFF_CONFIG="/Users/john.archer/ls/share/snpeff-5.4.0c-0/snpEff.config"
SNPEFF_DATA="/Users/john.archer/ls/share/snpeff-5.4.0c-0/data"
GENOME="beta_tubulin_isotype_1"
REF_FASTA="/Users/john.archer/Documents/Glasgow/anthelmogram/illumina_runs/reference_sequence_databases/beta_tub_iso-1_consensus_sequences_JA_2026.fasta" ### <- */reference_sequence_databases/beta_tub_iso-1_consensus_sequences_JA_2026.fasta
GFF3="/Users/john.archer/Documents/Glasgow/anthelmogram/illumina_runs/reference_sequence_databases/beta_tubulin_isotype_1_NEW.gff3" ### <- */reference_sequence_databases/beta_tubulin_isotype_1_NEW.gff3

# check required files exist
[ -f "$SNPEFF_JAR" ] || { echo "error: snpEff.jar not found"; exit 1; }
[ -f "$SNPEFF_CONFIG" ] || { echo "error: snpEff.config not found"; exit 1; }
[ -f "$REF_FASTA" ] || { echo "error: reference fasta not found"; exit 1; }
[ -f "$GFF3" ] || { echo "error: gff3 file not found"; exit 1; }

### check reference sequence identifiers match gff3 identifiers
FASTA_IDS=$(grep "^>" "$REF_FASTA" | sed 's/^>//' | awk '{print $1}' | sort)
GFF3_IDS=$(grep -v "^#" "$GFF3" | cut -f1 | sort -u)

if [ "$FASTA_IDS" != "$GFF3_IDS" ]; then
    echo "error: FASTA and GFF3 sequence identifiers do not match"
    echo "FASTA identifiers:"
    echo "$FASTA_IDS"
    echo "GFF3 identifiers:"
    echo "$GFF3_IDS"
    exit 1
fi

# prepare genome folder
rm -rf "$SNPEFF_DATA/$GENOME"
mkdir -p "$SNPEFF_DATA/$GENOME"
cp "$GFF3" "$SNPEFF_DATA/$GENOME/genes.gff"
cp "$REF_FASTA" "$SNPEFF_DATA/$GENOME/sequences.fa"

# build SnpEff database
java -jar "$SNPEFF_JAR" build \
  -gff3 \
  -v \
  -c "$SNPEFF_CONFIG" \
  -dataDir "$SNPEFF_DATA" \
  -noCheckCds \
  -noCheckProtein \
  "$GENOME"

# check successfully built
[ -s "$SNPEFF_DATA/$GENOME/snpEffectPredictor.bin" ] || { echo "error: SnpEff database build failed"; exit 1; }

# check database
java -jar "$SNPEFF_JAR" dump \
  -c "$SNPEFF_CONFIG" \
  -dataDir "$SNPEFF_DATA" \
  "$GENOME" > "$SNPEFF_DATA/$GENOME/database_check.txt"

echo "build_SnpEff_database.sh complete"