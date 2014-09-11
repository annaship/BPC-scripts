#!/bin/bash

for f_db in *.db
do
  for f_txt in *.txt
    #echo "Processing $f"
    all_lines=`wc -l $f | awk '{print $1}'`
  chim_f_name="$f.chimeric.fa"
  #echo "chim_f_name = $chim_f_name"
  chimeric=`grep "^>" $chim_f_name | wc -l`
  #percent_chim=`echo "scale=1; $chimeric * 100 / $all_lines" | bc`
  percent_chim=`echo "$chimeric $all_lines" | awk '{printf "%.1f", $1 * 100 / $2}'`
  #echo "all_lines = $all_lines"
  #echo "chimeric = $chimeric"
  echo "Percent chimeric ref in $f = $percent_chim"
done
