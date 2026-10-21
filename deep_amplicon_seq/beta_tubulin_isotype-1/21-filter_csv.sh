#!/bin/bash
### format mutation abundance data prior to plotting
# 1. remove rows with Total_depth < 200
# 2. if AF < 0.01: 
#       set AF = 0
#       set Resistant_reads = 0
#       set Effect = 'NA'
#       set Protein_change = 'NA'
#       set Codon_change = 'NA'
# 3. add Protein_change_all across all three bases of each codon (NOTE: removes preceding 'p.' and also converts codon number to mutation codon number (e.g., 'Phe28tyr' becomes 'Phe167Tyr'))
# 4. add Resistance_allele_frequency (highest mutation AF across the three bases of each codon)
# 5. add Susceptible_allele_frequency (= 1 - Codon_allele_frequency)
set -euo pipefail
shopt -s nullglob

# input csv generated using merge_vardict-SnpEff_and_mpileup.sh
IN="" ### <- */beta_tubulin_codons_merged.csv

# output new csv
OUT="" ### <- */beta_tubulin_codons_merged_FILTERED.csv

# format
awk -F',' '
BEGIN{
    OFS=","
}

# header
NR==1{

    print $0,"Protein_change_all","Resistance_allele_frequency","Susceptible_allele_frequency"
    next

}

{

    # remove Windows carriage return if present
    sub(/\r$/,"",$0)

    # skip malformed rows
    if (NF != 12)
        next

    depth=$8+0
    af=$9+0

    # remove low depth rows (< 200)
    if(depth < 200)
        next

    # remove low frequency variants (< 1%)
    if(af < 0.01){

        $7=0           # Resistant_reads
        $9=0           # AF
        $10="NA"       # Effect
        $11="NA"       # Protein_change
        $12="NA"       # Codon_change

        af=0

    }

    # key for each codon within each sample/species
    key=$1 FS $2 FS $5

    # store amino acid change if present
    if($11 != "NA" && $11 != ""){

        aa=$11

        # remove p.
        sub(/^p\./,"",aa)

            # convert amplicon amino-acid positions to beta-tubulin codon numbers
            gsub(/28/, "167", aa)
            gsub(/59/, "198", aa)
            gsub(/61/, "200", aa)

        protein[key]=aa

    }

    # store highest AF for each codon
    if(!(key in maxaf) || af > maxaf[key])
        maxaf[key]=af

    # store filtered rows
    row[++n]=$0
    rowkey[n]=key

}

END{

    # output rows with propagated protein change,
    # codon allele frequency,
    # susceptible allele frequency

    for(i=1;i<=n;i++){

        key=rowkey[i]

        if(key in protein)
            aa=protein[key]
        else
            aa="NA"

        if(key in maxaf)
            caf=maxaf[key]
        else
            caf=0

        saf=1-caf

        # avoid floating point artefacts
        if(caf < 0.000001)
            caf=0

        if(saf < 0.000001)
            saf=0

        printf "%s,%s,%.5f,%.5f\n", row[i], aa, caf, saf

    }

}

' "$IN" > "$OUT"

echo "filter_csv.sh done"