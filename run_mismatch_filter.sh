#!/bin/bash

title="Filtering v4v5 merged. Run on grendel."

echo "$title"

for file in *MERGED
do
  echo "============="
  echo $file
  clusterize filter-merged-reads $file --output ${file}_FILTERED
done

