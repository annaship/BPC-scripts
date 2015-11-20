#!/bin/bash

gunzip *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa.gz
ls *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa >nonchimeric_files.list
FILE_NUMBER=`wc -l < nonchimeric_files.list`
echo "total files = $FILE_NUMBER"
DIRECTORY_NAME="DIRECTORY_NAME"
# basename `pwd`
echo "DIRECTORY_NAME = $DIRECTORY_NAME"
NAME_PAT="*.unique.nonchimeric.fa"
UDB_NAME="refv4v5"
ITS_OPTION=""


cat >clust_gast_ill_$DIRECTORY_NAME.sh <<InputComesFromHERE
#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N clust_gast_ill_$DIRECTORY_NAME.sh
# Giving the name of the output log file
#$ -o clust_gast_ill_$DIRECTORY_NAME.sh.sge_script.sh.log
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

  echo "/bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in \$INFILE -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out ${PWD}/\$INFILE.gast"

InputComesFromHERE

