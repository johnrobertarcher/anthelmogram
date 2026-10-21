#!/bin/bash
### uses generated [*/BLASTn_output.tsv] to perform kNN (kNN = 3)
set -euo pipefail
shopt -s nullglob

# input */BLASTn_output.tsv
BLAST_OUT="" ### <- */BLASTn_output.tsv

# output
KNN_OUT="" ### <- */kNN_taxonomy.tsv

# kNN classifier (kNN = 3)
echo "running kNN classifier"

awk -F'\t' '
BEGIN {
    OFS="\t"
    print "QueryID", "Assignment"
}

{
    q = $1
    s = $2

    split(s, a, "_")

    genus   = a[1]
    species = a[1] "_" a[2]

    hit[q]++
    idx = hit[q]

    sp[q, idx] = species
    gn[q, idx] = genus
}

END {

    for (q in hit) {

        # require all three nearest neighbours
        if (hit[q] < 3) {
            print q, "unclassified"
            continue
        }

        # species consensus
        same_sp = 1
        ref_sp = sp[q,1]

        for (i = 2; i <= 3; i++) {
            if (sp[q,i] != ref_sp) {
                same_sp = 0
                break
            }
        }

        if (same_sp) {

            print q, ref_sp

        } else {

            # genus consensus
            same_gn = 1
            ref_gn = gn[q,1]

            for (i = 2; i <= 3; i++) {
                if (gn[q,i] != ref_gn) {
                    same_gn = 0
                    break
                }
            }

            # no consensus
            if (same_gn) {
                print q, ref_gn "_sp"
            } else {
                print q, "unclassified"
            }
        }
    }
}
' "$BLAST_OUT" > "$KNN_OUT"

echo "kNN.sh complete"