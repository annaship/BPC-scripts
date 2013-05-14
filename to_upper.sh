#!/bin/bash

for file in *-MAX-MISMATCH-3 
do
  echo "============="
  echo $file
  clusterize tr '[:lower:]' '[:upper:]' <$file >$file.upper

done

