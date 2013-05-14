#!/bin/bash

USAGE="Run in the directory with gast results. Shows 1) Number of lines in each file; 2) Amount of \"Unknowns\" per file."
echo -e "\e[1;34mThis is a blue text.\e[0m"
CYAN="\[\033[0;36m\]"
BLACK="\e[0m"
echo $USAGE
for file in *gast
do
echo "================"
lines=`wc -l $file`
unknowns=`grep Unknown $file | wc -l`
line_number=`echo $lines | awk '{print $1}'`
perc=$(echo "$unknowns * 100 / $line_number" | bc -l)
echo "Lines in file: $lines"
echo "Unknowns in file: $unknowns"

echo $perc | awk '{if ($perc > 10) print "\033[1;34mPercent unknowns:" $perc"\033[0m"}'

done
