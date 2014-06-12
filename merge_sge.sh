20130408_1_b_reads_overlap
create_chimera_cmd - clusterize in pipline
#!/bin/bash

for fullfile in *.ini
do
  echo "============="
  echo $fullfile
  file_idx_key=$(basename "$fullfile")
  file_idx_key="${file_idx_key%.*}"
  #echo "file_idx_key = $file_idx_key"
  clusterize /bioware/merens-illumina-utils/scripts/merge-illumina-pairs $fullfile $file_idx_key
done

/xraid/bioware/linux/seqinfo/bin/run_partial_overlap_clust.sh (END) 


#!/bin/bash

for fullfile in *.ini
do
  echo "============="
  echo $fullfile
  file_idx_key=$(basename "$fullfile")
  file_idx_key="${file_idx_key%.*}"
  #echo "file_idx_key = $file_idx_key"
  merge-illumina-pairs --enforce-Q30-check --marker-gene-stringent $fullfile
done

/xraid/bioware/linux/seqinfo/bin/run_partial_overlap_no_clust.sh (END) 

===
2. Make a list of files with something like
`ls *fa > MyFiles.list` (you get to decide how to deal with
MyBigFile.fa, which shouldn't be in the list)

3. make a script like this one
-----------------
#!/bin/bash

#$ -cwd
#$ -S /bin/bash
# This next line is the important one, it says loop 1-n times; Rich's
link shows some variations
#$ -t 1-59609
# Now the script will iterate 59609 times.  The iteration number is
stored in the env variable $SGE_TASK_NUMBER
# so you can use that variable to access the nth line in a file, or
other more creative things

LISTFILE=./MyFiles.list
INFILE=`sed -n "${SGE_TASK_ID}p" $LISTFILE`
# or
# INFILE=`awk "NR==$SGE_TASK_ID" $LISTFILE`
# but I like sed

blastx -query $INFILE -db refseq_protein -outfmt 5 -max_target_seqs 1
-out $INFILE.br

-------------------
4. make it executable and then run it:
`qsub -V script`
===
#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N sequence_ill.txt
# Giving the name of the output log file
#$ -o sequence_ill.txt.sge_script.sh.log
# Combining output/error messages into one file
#$ -j y
# Send mail to these users
#$ -M ashipunova@mbl.edu
# Send mail at job end; -m eas sends on end, abort, suspend.
#$ -m eas
#$ -t 1-108
# Now the script will iterate 108 times.

echo ".sequence_ill.txt.out_db.$SGE_TASK_ID.job.sh"
./sequence_ill.txt.out_db.$SGE_TASK_ID.job.sh
sequence_ill.txt.out_db.sge_script.sh (END) 
