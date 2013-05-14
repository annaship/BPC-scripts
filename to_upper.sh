#!/bin/bash

for file in *FILTERED 
do
  echo "============="
  echo $file
  clusterize tr '[:lower:]' '[:upper:]' <$file >$file.upper

done

