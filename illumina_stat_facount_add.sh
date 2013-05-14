#!/bin/bash
# auxilary file for illumina_stat_facount.sh

for f in $*
do
 echo $f
 facount $f
done

