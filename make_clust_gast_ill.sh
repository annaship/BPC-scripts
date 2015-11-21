#!/bin/bash

gunzip *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa.gz
DIRECTORY_NAME=`pwd`

mkdir gast_silva119
ls *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa >gast_silva119/nonchimeric_files.list

cd gast_silva119

FILE_NUMBER=`wc -l < nonchimeric_files.list`
echo "total files = $FILE_NUMBER"
# RUN_LANE="RUN_LANE"
RUN_LANE=`pwd | sed 's,^/xraid2-2/g454/run_new_pipeline/illumina/\(.*\)/\(lane_1_[^/]*\)/.*,\1_\2,g'`
echo "RUN_LANE = $RUN_LANE"
NAME_PAT="*.unique.nonchimeric.fa"
UDB_NAME="refv4v5"
ITS_OPTION=""


cat >clust_gast_ill_$RUN_LANE.sh <<InputComesFromHERE
#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N clust_gast_ill_$RUN_LANE.sh
# Giving the name of the output log file
#$ -o clust_gast_ill_$RUN_LANE.sh.sge_script.sh.log
# Combining output/error messages into one file
#$ -j y
# Send mail to these users
#$ -M ashipunova@mbl.edu
# Send mail at job end; -m eas sends on end, abort, suspend.
#$ -m eas
#$ -t 1-$FILE_NUMBER
# Now the script will iterate $FILE_NUMBER times.

  LISTFILE=./nonchimeric_files.list
  INFILE=\`sed -n "\${SGE_TASK_ID}p" \$LISTFILE\`
  echo "file name is \$INFILE"

  echo "/bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in $DIRECTORY_NAME/\$INFILE -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out $DIRECTORY_NAME/gast_silva119/\$INFILE.gast -uc $DIRECTORY_NAME/gast_silva119/\$INFILE.uc"

InputComesFromHERE

