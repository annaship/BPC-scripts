#!/bin/bash

gunzip *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa.gz
ls *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa >nonchimeric_files.list
FILE_NUMBER=`wc -l nonchimeric_files.list`
echo "total files = $FILE_NUMBER"
DIRECTORY_NAME="DIRECTORY_NAME"
# basename `pwd`
echo "DIRECTORY_NAME = $DIRECTORY_NAME"

cat >clust_gast_ill_$DIRECTORY_NAME.sh <<InputComesFromHERE
TEXT here
InputComesFromHERE

