#!/bin/bash

USAGE="Run in the directory with gast results. Shows 1) Number of lines in each file; 2) Amount of \"Unknowns\" per file."

echo $USAGE
for file in *gast
do
echo "================"
wc -l $file
grep Unknown $file | wc -l
done
