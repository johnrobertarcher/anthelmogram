#!/bin/bash
### generate SnpEff-compatible GFF3 for beta-tubulin isotype-1 amplicons. NOTE: uses fixed exon structure --- exon1: 1–105 --- exon2: last 120 bp - intron: between these two exons
set -euo pipefail

# input FASTA.fai
FAI="//Users/john.archer/Documents/Glasgow/anthelmogram/illumina_runs/reference_sequence_databases/beta_tub_iso-1_consensus_sequences_JA_2026.fasta.fai"

# output
OUT="/Users/john.archer/Documents/GitHub/anthelmogram/deep_amplicon_seq/reference_databases/beta_tubulin_isotype-1/beta_tubulin_isotype-1_JA.gff3"

# generate gff3
echo "##gff-version 3" > "$OUT"

# loop
while read -r contig length _; do

    exon1_start=1
    exon1_end=105

    exon2_start=$((length - 120 + 1))
    exon2_end=$length

    intron_start=$((exon1_end + 1))
    intron_end=$((exon2_start - 1))

    gene_id="${contig}"
    mrna_id="${contig}.mRNA"

    # gene
    printf "%s\tcustom\tgene\t1\t%d\t.\t+\t.\tID=%s\n" \
        "$contig" "$length" "$gene_id" >> "$OUT"

    # mRNA
    printf "%s\tcustom\tmRNA\t1\t%d\t.\t+\t.\tID=%s;Parent=%s\n" \
        "$contig" "$length" "$mrna_id" "$gene_id" >> "$OUT"

    # exon 1
    printf "%s\tcustom\texon\t%d\t%d\t.\t+\t.\tID=%s.exon1;Parent=%s\n" \
        "$contig" "$exon1_start" "$exon1_end" "$contig" "$mrna_id" >> "$OUT"

    # CDS 1
    printf "%s\tcustom\tCDS\t%d\t%d\t.\t+\t0\tID=%s.cds1;Parent=%s\n" \
        "$contig" "$exon1_start" "$exon1_end" "$contig" "$mrna_id" >> "$OUT"

    # intron
    if [ "$intron_end" -gt "$intron_start" ]; then
        printf "%s\tcustom\tintron\t%d\t%d\t.\t+\t.\tParent=%s\n" \
            "$contig" "$intron_start" "$intron_end" "$mrna_id" >> "$OUT"
    fi

    # exon 2
    printf "%s\tcustom\texon\t%d\t%d\t.\t+\t.\tID=%s.exon2;Parent=%s\n" \
        "$contig" "$exon2_start" "$exon2_end" "$contig" "$mrna_id" >> "$OUT"

    # CDS 2
    printf "%s\tcustom\tCDS\t%d\t%d\t.\t+\t0\tID=%s.cds2;Parent=%s\n" \
        "$contig" "$exon2_start" "$exon2_end" "$contig" "$mrna_id" >> "$OUT"

done < "$FAI"

echo "create_beta_tubulin_isotype-1.sh complete"