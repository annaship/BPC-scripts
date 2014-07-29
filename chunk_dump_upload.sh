#! /bin/bash

# Ash May 30 2014, Jun 6 2014, Jul 25 2014
# (Could be run from vamps_ror_upload.sh)
# Devides a huge table query into chunk_size chunks, writes a SGE script to run on a cluster to get and send data from/to a db
# This script can be run on any server and the resulting scripts only on cricket (grendel has a different qsub)

function helpmessage {
  cat <<HEREUSAGE
  ------------------------------------------
  This will create 2 scripts and run_on_server.txt with their full command lines to be run on cricket.
  Please provide a source table id name, a (biggest) source table name, a comma separated column names list and the original select query.
  USAGE $0 source_id_name source_table_name target_table_name target_field_names query_orig [dbhost_from dbname_from dbhost_from dbname_from]
  ------------------------------------------
  EXAMPLE:
  query_orig="SELECT DISTINCT sequence_comp, taxonomy, gast_distance, refssu_id, refssu_count, rank, refhvr_ids
      FROM sequence_uniq_info_ill 
      JOIN sequence_ill USING(sequence_ill_id) 
      JOIN rank USING(rank_id) 
      JOIN taxonomy USING(taxonomy_id)
  "
  column_names="sequence_comp, taxonomy, gast_distance, refssu_id, refssu_count, rank, refhvr_ids"

  ../chunk_dump_upload.sh sequence_uniq_info_ill_id sequence_uniq_info_ill sequence_uniq_infos_interim "\$column_names" "\$query_orig"
  ------------------------------------------
HEREUSAGE
}

ARGV=$@
ARGC=$#
if [ $ARGC -lt 4 ]; then helpmessage; exit; fi
  
id_name=$1
source_table_name=$2
target_table_name=$3
column_names=$4
query_orig=$5
dbhost_from=$6
dbname_from=$7
dbhost_from=$8
dbname_from=$9

if ["$dbhost_from" = ""]; then dbhost_from="newbpcdb2"; fi
if ["$dbname_from" = ""]; then dbname_from="env454"; fi
# if ["$dbhost_from" = ""]; then dbhost_from="vampsdev"; fi
# if ["$dbname_from" = ""]; then dbname_from="vamps2"; fi
if ["$dbhost_to" = ""]; then dbhost_to="vampsdev"; fi
if ["$dbname_to" = ""]; then dbname_to="vamps2"; fi

echo "id_name = $id_name; source_table_name = $source_table_name; target_table_name = $target_table_name; column_names = $column_names"
echo "dbhost_from = $dbhost_from; dbname_from = $dbname_from; dbhost_to = $dbhost_to; dbname_to = $dbname_to"
echo "query_orig = $query_orig"

user_name=`whoami`


chunk_size=500000
# chunk_size=5
echo "mysql -e \"select count($id_name) from $source_table_name;\" -u $user_name -h $dbhost_from $dbname_from"
id_cnts_str=`mysql -e "select count($id_name) from $source_table_name;" -u $user_name -h $dbhost_from $dbname_from`
id_cnts=`echo $id_cnts_str | cut -d" " -f2`
# id_cnts=10
echo "id_cnts = $id_cnts"

file_name=$source_table_name".txt"
echo "file_name = $file_name"

get_data() 
{
    query="$query_orig \
    JOIN ( \
        SELECT $id_name FROM $source_table_name ORDER BY $id_name \
        LIMIT $from_here, $chunk_size \
        ) AS t USING($id_name)"
    # echo "time mysql -e \"$query\" -u $user_name -h newbpcdb2 env454 > $out_file"
    # mysql -e "$query" -u $user_name -h newbpcdb2 env454 > $out_file
    echo "#! /bin/bash" > $file_name.out_db.$file_number.job.sh
    echo "time mysql -e \"$query\" -u $user_name -h $dbhost_from $dbname_from > $out_file" >> $file_name.out_db.$file_number.job.sh
    chmod u+x $file_name.out_db.$file_number.job.sh
    
}

upload_data()
{
    upload_cmd="LOAD DATA LOCAL INFILE '$out_file' INTO TABLE $target_table_name FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES ($column_names)"
    echo "#! /bin/bash" > $file_name.in_db.$file_number.job.sh
    echo "time mysql -e \"$upload_cmd\"  -u $user_name -h $dbhost_to $dbname_to" >> $file_name.in_db.$file_number.job.sh
    chmod u+x $file_name.in_db.$file_number.job.sh
    # too slow, run parallel on a cluster, see make_sge_script
    # mysql -e "$upload_cmd"  -u $user_name -h vampsdev vamps2
    # upload_cmd="mysqlimport --compress --verbose --ignore-lines=1 --local --columns=$column_names -h vampsdev vamps2 $out_file"
}

make_sge_script()
{
    cat << InputComesFromHERE > $job_file_name_prefix.sge_script.sh
#!/bin/bash

#$ -cwd
#$ -S /bin/bash
#$ -N $file_name
# Giving the name of the output log file
#$ -o $file_name.sge_script.sh.log
# Combining output/error messages into one file
#$ -j y
# Send mail to these users
#$ -M $user_name@mbl.edu
# Send mail at job end; -m eas sends on end, abort, suspend.
#$ -m eas
#$ -t 1-$biggest_number
# Now the script will iterate $biggest_number times.

echo ".$job_file_name_prefix.\$SGE_TASK_ID.job.sh"
./$job_file_name_prefix.\$SGE_TASK_ID.job.sh
InputComesFromHERE

chmod u+x $job_file_name_prefix.sge_script.sh
}

print_todo()
{
    echo "# Please run"
    echo "cd `pwd`; qsub $joblimit $job_file_name_prefix.sge_script.sh"
    echo "# on cricket"    
}


print_commands()
{
  echo "#! /bin/bash" > run_on_server.txt
  # -tc: If only one job-array is running on this database you can use 25 for "out" and 8 for "in"
  job_file_name_prefix=$file_name.out_db
  time make_sge_script
  joblimit="-tc 20" #no more then 20 output queries at the same time to avoid locks, works only on cricket
  print_todo >> run_on_server.txt
  job_file_name_prefix=$file_name.in_db
  time make_sge_script
  joblimit="-tc 7" #no more then 7 input queries at the same time to avoid locks, works only on cricket
  print_todo >> run_on_server.txt
  echo -e "setaf 4\nsetab 15\nbold" | tput -S 
  echo "Please see run_on_server.txt"
  echo $(tput sgr0)
}

dump_by_chunks() {
  from_here=0
  reads_left=$id_cnts
  file_number=1
  out_file=$file_name"_"$file_number
  while [  "$reads_left" -gt 0 ]; do
      #echo "reads_left = $reads_left"
      #echo "from_here = $from_here"
      
      get_data
      upload_data
      reads_left=$[$reads_left - $chunk_size]
      from_here=$[$from_here + $chunk_size]
      biggest_number=$file_number      
      file_number=$[$file_number+1]
      out_file=$file_name"_"$file_number
      #echo "========================"
  done
  
  echo "biggest_number = $biggest_number"
  
  print_commands
    
  return
}

dump_by_chunks
