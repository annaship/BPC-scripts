#!/bin/sh
cd /groups/vampsweb/new_vamps_maintenance_scripts/data/processing/results/reads_overlap/

r_keys="AACAGTAT ACCATACT ACCTCCCA AGAGAGGC AGCTGACG AGGCTTCA ATAGGTGG ATCGCACC ATGCCAGC CAACTTCA CACTCACT CAGCGGCA CCGACAAA CCGCACCG CGACATTC CGTCCCAC CTGTTAGT GAAACTGG GAGTTTGA GCAATGGA GCCTGTTC GGTAATGA GTAGTCGA GTGCTGAT TAAGGGAG TACGATAC TCAAAGCT TCCCGATG TCCGTGCG TCGAACAC TGGGACCT TGTTTCCC"

for rkey in $r_keys
do
    echo "rkey = $rkey"  
    python /xraid/bioware/linux/seqinfo/bin/subtract_chimeric.py -d /groups/vampsweb/new_vamps_maintenance_scripts/data/processing/results/reads_overlap -i "$rkey"_MERGED-MAX-MISMATCH-3.unique.chg
    sed 's/;size=/frequency:/g' "$rkey"_MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa >$$ 
    mv $$ "$rkey"_MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa 
    
done
