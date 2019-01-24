#!/bin/bash

# a) Demultiplex

# b) overlap
# for f in *.ini 
# do 
#     echo "Processing $f"
#     iu-merge-pairs --enforce-Q30-check "$f"
# done

# c) filter
# for f in *MERGED 
# do 
#     echo "Processing $f"
#     time iu-filter-merged-reads "$f"
# done

# d) unique
# for f in *MERGED-MAX-MISMATCH-3
# do 
#     echo "Processing $f"
#     time python /bioware/seqinfo/bin/fastaunique "$f"
# done

# e) Chimera checking 
# 1)
#     module load vsearch
# for f in *MERGED-MAX-MISMATCH-3
# do
#     echo "Processing $f".unique
#     time sed 's/frequency:/;size=/g' "$f".unique > "$f".unique.chg
# 
#     time vsearch -uchime_denovo "$f".unique.chg -uchimeout "$f".unique.chimeras.txt -chimeras "$f".unique.chimeras.txt.chimeric.fa -nonchimeras "$f".unique.chimeras.txt.nonchimeric.fa -notrunclabels 
# 
#     time vsearch -uchime_ref "$f".unique.chg -uchimeout "$f".unique.chimeras.db -chimeras "$f".unique.chimeras.db.chimeric.fa -nonchimeras "$f".unique.chimeras.db.nonchimeric.fa -notrunclabels -strand plus -db /groups/g454/blastdbs/rRNA16S.gold.fasta
# done

# 2) combine into one nonchimeras for both ref and denovo
for f in *MERGED-MAX-MISMATCH-3
do
    time python /xraid/bioware/linux/seqinfo/bin/fasta_two_lines.py -c  -e 'nonchimeric.fa' -ve 
    echo "Processing $f"
    cat "$f"*.concat.fa | sort -u > "$f".unique.nonchimeric.concat.fa
    time cat "$f".unique.nonchimeric.concat.fa | sed "s/^/>/" | tr "#" "\n" > "$f".unique.nonchimeric.fa
# 
# Please check if the counts look okay. The idea here is to combine nonchimeric sequences from denovo ("txt") and reference ("db") into one file. So I glued sequences to they headers, combined into one file and split them back to 2 lines each. The result should have the ".unique.nonchimeric.fa" suffix for gast script to find it at the next step.
done

# f) GAST (on grendel)
# 1)
run_gast_ill_nonchim_sge.sh 
# Choose option 8 (full length). It's pretty slow. Took me more then 3 hours for one file. Creates results in a dir "gast" above current, created automatically.

# 2)
percent10_gast_unknowns.sh
# Check if "Unknowns in file" is reasinable. If it is 99% - something is wrong.
