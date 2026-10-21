#!/bin/bash
### extract vardict SnpEff data from just codons of interest (167: 28; 198: 59; 200: 61) and extract read count data from vardict VCFs to plot
set -euo pipefail
shopt -s nullglob

# input
SNPEFF_DIR="" ### <- */SnpEff_output

# output
OUT="" ### <- */vardict_beta_tubulin_codons_167_198_200_abundance.tsv

# extract read count data
echo -e "Sample\tSpecies\tCHROM\tPOS\tREF\tALT\tEffect\tProtein_change\tCodon_change\tBeta_codon\tSusceptible_reads\tResistant_reads\tTotal_depth\tAF" \
> "$OUT"

### loop extraction
for vcf in "$SNPEFF_DIR"/*.snpeff.vcf
do

    sample=$(basename "$vcf" .snpeff.vcf)

    echo "processing $sample"

    bcftools query \
      -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/AF\t%INFO/DP\t[%AD]\t%INFO/ANN\n' \
      "$vcf" |
    while IFS=$'\t' read -r chrom pos ref alt af dp ad ann
    do

        # AD is REF,ALT read depth
        susceptible=$(echo "$ad" | cut -d',' -f1)
        resistant=$(echo "$ad" | cut -d',' -f2)

        IFS=',' read -ra annotations <<< "$ann"

        for a in "${annotations[@]}"
        do

            effect=$(echo "$a" | cut -d'|' -f2)

            # keep only amino-acid changing variants
            if [[ "$effect" != "missense_variant" ]]; then
             continue
            fi

            protein_change=$(echo "$a" | cut -d'|' -f11)
            codon_change=$(echo "$a" | cut -d'|' -f10)
            gene=$(echo "$a" | cut -d'|' -f4)

            protein_position=$(echo "$protein_change" \
                | grep -oE '[0-9]+' \
                | head -1 || true)

            case "$protein_position" in
                28)
                    beta_codon="167"
                    ;;
                59)
                    beta_codon="198"
                    ;;
                61)
                    beta_codon="200"
                    ;;
                *)
                    continue
                    ;;
            esac

            echo -e "${sample}\t${gene}\t${chrom}\t${pos}\t${ref}\t${alt}\t${effect}\t${protein_change}\t${codon_change}\t${beta_codon}\t${susceptible}\t${resistant}\t${dp}\t${af}" \
            >> "$OUT"

        done

    done

done

### convert .tsv to .csv for easy viewing
CSV="${OUT%.tsv}.csv"
sed 's/\t/,/g' "$OUT" > "$CSV"

echo "codon_data_extraction.sh done"