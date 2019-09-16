#!/bin/bash

USAGE="Run in the directory with gast results. Shows 1) Number of lines in each file; 2) Amount of \"Unknowns\" per file.
 If percent unknowns is greater then 1 it will be highlighted."

CYAN="\[\033[0;36m\]"

echo $USAGE
for file in *gast
do
echo "================"
lines=`wc -l $file`
unknowns=`grep Unknown $file | wc -l`
line_number=`echo $lines | awk '{print $1}'`
echo "Lines in file:    $lines"
echo "Unknowns in file: $unknowns"
# echo $perc | awk '{if ($perc > 10) print "\033[1;34mPercent unknowns:" $perc"\033[0m"}'
# to remove decimals:
perc=$( printf '%.0f' $(echo "$unknowns * 100 / $line_number" | bc -l) )
# echo "perc = $perc"
if [ $perc -gt 1 ]; then
  printf "\033[1;34mPercent unknowns: $perc \033[0m\n"
fi

done
