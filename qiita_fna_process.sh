#! /bin/bash

echo "time python /bioware/seqinfo/bin/demultiplex_qiita.py -i $1"
time python /bioware/seqinfo/bin/demultiplex_qiita.py -i $1

echo "for file in *.fa; do fastaunique $file; done"
for file in *.fa; do fastaunique $file; done

#grendel
curr_path=`pwd`
curr_dir=${PWD##*/} 
echo "Run on Grendel, change the reference file name accordingly:"
echo "cd $curr_path; run_gast_ill_qiita_sge.sh -s $curr_dir -d gast -v -e fa.unique -r refssu -f"

