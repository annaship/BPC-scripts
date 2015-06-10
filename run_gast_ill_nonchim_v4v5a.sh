#!/bin/bash

title="Illumina gast for v4v5a. Run on grendel."


prompt="Please select a file name pattern:"
echo "$title"

NAME_PAT="*.unique.nonchimeric.fa"
UDB_NAME="refv4v5a"

echo "UDB_NAME = $UDB_NAME.udb"
for file in $NAME_PAT
do
  echo "============="
  echo $file
  clusterize /bioware/seqinfo/bin/gast_ill -saveuc -nodup  -in $file -db /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.fa -rtax /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.tax -out $file.gast
done

