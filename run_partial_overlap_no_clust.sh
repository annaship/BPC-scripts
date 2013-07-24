#!/bin/bash

for fullfile in *.ini
do
  echo "============="
  echo $fullfile
  file_idx_key=$(basename "$fullfile")
  file_idx_key="${file_idx_key%.*}"
  #echo "file_idx_key = $file_idx_key"
  /bioware/merens-illumina-utils/scripts/merge-illumina-pairs --enforce-Q30-check --slow-merge $fullfile
done

