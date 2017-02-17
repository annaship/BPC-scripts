#!/bin/bash

USAGE="Run in the directory with gast results. Shows 1) Number of lines in each file; 2) Amount of \"Unknowns\" per file."

echo $USAGE
for file in *gast
do
    echo "================"
    echo $file
    # wc -l $file
    # grep Unknown $file | wc -l

    total=`wc -l <$file`
    echo "$total - 1" | bc
    unknowns=`grep Unknown $file | wc -l`
    echo $unknowns

    echo "%"
    echo "scale=2;$unknowns*100/($total-1)" | bc
done
