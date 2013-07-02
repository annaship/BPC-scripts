#!/bin/bash

for fullfile in *.ini
do
  echo "============="
  echo $fullfile
  file_idx_key=$(basename "$fullfile")
  file_idx_key="${file_idx_key%.*}"
  #echo "file_idx_key = $file_idx_key"
  # clusterize /bioware/merens-illumina-utils/scripts/merge-illumina-pairs --fast-merge --compute-qual-dicts $fullfile $file_idx_key
  clusterize /bioware/merens-illumina-utils/scripts/merge-illumina-pairs $fullfile $file_idx_key
done

