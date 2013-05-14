#!/bin/bash

for file in *.ini
do
  echo "============="
  echo $file
  clusterize /bioware/seqinfo/bin/analyze-illumina-v6-overlaps $file
done

