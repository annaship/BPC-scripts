#!/bin/sh

cd /groups/vampsweb/new_vamps_maintenance_scripts/data/processing/results/reads_overlap

r_keys="AACAGTAT ACCATACT ACCTCCCA AGAGAGGC AGCTGACG AGGCTTCA ATAGGTGG ATCGCACC ATGCCAGC CAACTTCA CACTCACT CAGCGGCA CCGACAAA CCGCACCG CGACATTC CGTCCCAC CTGTTAGT GAAACTGG GAGTTTGA GCAATGGA GCCTGTTC GGTAATGA GTAGTCGA GTGCTGAT TAAGGGAG TACGATAC TCAAAGCT TCCCGATG TCCGTGCG TCGAACAC TGGGACCT TGTTTCCC"


for rkey in $r_keys
do
    echo "rkey = $rkey"
    iu-filter-merged-reads "$rkey"_MERGED
    python /bioware/seqinfo/bin/fastaunique "$rkey"_MERGED-MAX-MISMATCH-3
done
