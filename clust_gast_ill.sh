#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N clust_gast_ill_20151109_lane_1_B.sh
# Giving the name of the output log file
#$ -o clust_gast_ill_20151109_lane_1_B.sh.sge_script.sh.log
# Combining output/error messages into one file
#$ -j y
# Send mail to these users
#$ -M ashipunova@mbl.edu
# Send mail at job end; -m eas sends on end, abort, suspend.
#$ -m eas
#$ -t 1-2
# Now the script will iterate 2 times.

  ITS_OPTION=""
  NAME_PAT="*.unique.nonchimeric.fa"
  UDB_NAME="refv4v5"
  LISTFILE=./MyFiles.list
  INFILE=`sed -n "${SGE_TASK_ID}p" $LISTFILE`
  # file_list=(TAGCTT_NNNNGTATC_1.ini... CGATGT_NNNNCTAGC_1.ini)
  
  echo "file name is $INFILE"
  
  # i=$(expr $SGE_TASK_ID - 1)
#   echo "i = $i"
  # . /etc/profile.d/modules.sh
  # . /xraid/bioware/bioware-loader.sh
  # . /xraid/bioware/Modules/etc/profile.modules
  # module load bioware
    
  # echo "clust_gast_ill ${file_list[$i]}"
  # clust_gast_ill ${file_list[$i]}

  echo "/bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in $INFILE -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out ${PWD}/$INFILE.gast"
