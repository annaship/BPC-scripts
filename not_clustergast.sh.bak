#!/bin/bash

# 20080114 -reg v6_dutch
run=$1
reg=$2

time db2fasta -d env454 -sql "SELECT read_id, uncompress(trimsequence.sequence_comp) as sequence 
          FROM trimseq join trimsequence using(trimsequence_id)
          join dna_region using(dna_region_id)
          JOIN run using(run_id)
          WHERE  run = '$run' and dna_region = '$reg'" -o ${run}_$reg.fa

time mothur "#unique.seqs(fasta=${run}_$reg.fa);"

time usearch -usearch_global ${run}_$reg.unique.fa -gapopen 0E -gapext 0E -uc_allhits -strand both -db /xraid2-2/g454/blastdbs/gast_distributions/refssu.udb -uc ${run}_$reg.uc.txt -maxaccepts 15 -maxrejects 0 -id 0.7

time grep -P "^H\t" ${run}_$reg.uc.txt | sed -e 's/|.*$//' | awk '{print $9 "\t" $4 "\t" $10 "\t" $8}' | sort -k1,1b -k2,2gr | clustergast_tophit -ignore_terminal_gaps > gast_${run}_$reg.txt

time /usr/local/mysql/bin/mysqlimport -C -v -L --columns='read_id','refhvr_id','distance','alignment' -h newbpcdb2 env454 gast_${run}_$reg.txt

