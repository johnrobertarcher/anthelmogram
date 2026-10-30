#!/bin/bash
### merge VarDict/SnpEff mutation data and mpileup susceptible/resistant read count data
### extract beta tubulin resistance codons:
# 1. beta-tubulin codon 167 = SnpEff protein position 28
# 2. beta-tubulin codon 198 = SnpEff protein position 59
# 3. beta-tubulin codon 200 = SnpEff protein position 61
set -euo pipefail

# input bcftools output
MPILEUP_DIR="" ### <- */bcftools_output

# input SnpEff output
SNPEFF_DIR="" ### <- */SnpEff_output

# input curated [bcftools_BED_coordinates.bed] file
BED="" ### <- */reference_databases/beta_tubulin_isotype-1/bcftools_BED_coordinates.bed

# output (.tsv then convered to .csv)
OUT="" ### <- */beta_tubulin_codons_merged.tsv
CSV="${OUT%.tsv}.csv"
HEADER="Sample\tSpecies\tCHROM\tPOS\tBeta_codon\tSusceptible_reads\tResistant_reads\tTotal_depth\tAF\tEffect\tProtein_change\tCodon_change"
echo -e "$HEADER" > "$OUT"



### extract all bcftools mpileup posistions
for vcf in "$MPILEUP_DIR"/*.vcf.gz

do

    sample=$(basename "$vcf" .vcf.gz)

    echo "processing $sample"

    bcftools query \
    -f '%CHROM\t%POS\t%REF\t%ALT\t%INFO/DP\t[%AD]\n' \
    "$vcf" |

    while IFS=$'\t' read -r chrom pos ref alt dp ad

    do

        beta_codon=$(awk -v c="$chrom" -v p="$pos" '
        $1==c && p >= $2 && p <= $3 {print $4}
        ' "$BED")

        [ -z "$beta_codon" ] && continue

        susceptible=$(echo "$ad" | cut -d',' -f1)

        resistant=$(echo "$ad" | cut -d',' -f2)


        # bcftools sometimes gives missing ALT depth
        if [ -z "$resistant" ]
        then
            resistant=0
        fi

        if [ -z "$susceptible" ]
        then
            susceptible=0
        fi

        AF=$(awk -v r="$resistant" -v d="$dp" '
        BEGIN {
            if(d>0)
                printf "%.5f", r/d
            else
                print "0"
        }')

        species=$(echo "$chrom" | sed 's/_beta//')

        echo -e \
        "${sample}\t${species}\t${chrom}\t${pos}\t${beta_codon}\t${susceptible}\t${resistant}\t${dp}\t${AF}\tNA\tNA\tNA" \
        >> "$OUT"

    done

done



### extract SnpEff annotations
ANN_TMP=$(mktemp)
for vcf in "$SNPEFF_DIR"/*.snpeff.vcf

do

    sample=$(basename "$vcf" .snpeff.vcf)

    bcftools query \
    -f '%CHROM\t%POS\t%INFO/AF\t[%AD]\t%INFO/ANN\n' \
    "$vcf" |

    while IFS=$'\t' read -r chrom pos af ad ann

    do

        IFS=',' read -ra annotations <<< "$ann"

        for a in "${annotations[@]}"

        do

            effect=$(echo "$a" | cut -d'|' -f2)

            # only retain amino acid changing mutations
            if [ "$effect" != "missense_variant" ]
            then
                continue
            fi

            protein_change=$(echo "$a" | cut -d'|' -f11)
            codon_change=$(echo "$a" | cut -d'|' -f10)
            aa_position=$(echo "$protein_change" |
            grep -oE '[0-9]+' |
            head -1)

            case "$aa_position" in

                28)
                    beta_codon=167
                    ;;

                59)
                    beta_codon=198
                    ;;

                61)
                    beta_codon=200
                    ;;

                *)
                    continue
                    ;;

            esac
    
            echo -e \
            "${sample}\t${chrom}\t${pos}\t${beta_codon}\t${af}\t${effect}\t${protein_change}\t${codon_change}" \
            >> "$ANN_TMP"

        done

    done

done



### merge SnpEff output to mpileup output
awk -F'\t' '
NR==FNR {

    key=$1 FS $2 FS $3

    ann[key]=$5 FS $6 FS $7 FS $8

    next

}

{

    key=$1 FS $3 FS $4

    if(key in ann)

    {

        split(ann[key],x,FS)

        $9=x[1]
        $10=x[2]
        $11=x[3]
        $12=x[4]

    }

    print

}

' OFS='\t' "$ANN_TMP" "$OUT" > "${OUT}.tmp"

mv "${OUT}.tmp" "$OUT"
rm "$ANN_TMP"



### convert .tsv to .csv
tr '\t' ',' < "$OUT" > "$CSV"

echo "merge_vardict-SnpEff_and_mpileup.sh done"