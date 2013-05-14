#!/bin/bash

for file in *.fa
do
  echo "============="
  echo $file
  /bioware/seqinfo/bin/fastaunique $file
done

