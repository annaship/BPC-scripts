#!/bin/bash

run_reg=$1
echo "run_reg = $run_reg"


mysql_cnt=`mysql -h bpcdb1.mbl.edu env454 -e "SELECT COUNT(distinct read_id) FROM gast_$run_reg" | grep [0-9]`
# +-------------------------+
# | COUNT(distinct read_id) |
# +-------------------------+
# |                   13355 |
# +-------------------------+
echo "mysql_cnt = $mysql_cnt"

gast_files=`cat $run_reg/gast_$run_reg.*txt | cut -f1 | sort -u | wc -l`
# 13355
echo "gast_files = $gast_files"

fa_cnt=`facount $run_reg/*.unique.fa`
# 19483
echo "fa_cnt = $fa_cnt"

echo "scale=1; $fa_cnt/$mysql_cnt" | bc
# 1.4

