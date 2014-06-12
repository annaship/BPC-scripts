#! /bin/bash

# Ash Fri May 30 17:55:25 EDT 2014, Fri Jun  6 16:08:38 EDT 2014
# Run from vamps_ror_upload.sh 
# Devides query to a huge table into chunk_size=500000 chunks, writes a SGE script to run on a cluster to get and send data from/to a db

ARGV=$@
ARGC=$#
if [ $ARGC -lt 4 ]; then echo "Please provide an id name, a table name and a comma separated column names list."; echo "USAGE $0 source_id_name source_table_name target_table_name target_field_names query_orig"; exit; fi
 
id_name=$1
source_table_name=$2
target_table_name=$3
column_names=$4
query_orig=$5
echo "id_name = $id_name; source_table_name = $source_table_name; target_table_name = $target_table_name; column_names = $column_names"
echo "$query_orig"

chunk_size=500000
# chunk_size=5
echo "mysql -e \"select count($id_name) from $source_table_name;\" -u ashipunova -h newbpcdb2 env454"
id_cnts_str=`mysql -e "select count($id_name) from $source_table_name;" -u ashipunova -h newbpcdb2 env454`
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
    # echo "time mysql -e \"$query\" -u ashipunova -h newbpcdb2 env454 > $out_file"
    # mysql -e "$query" -u ashipunova -h newbpcdb2 env454 > $out_file
    echo "#! /bin/bash" > $file_name.out_db.$file_number.job.sh
    echo "time mysql -e \"$query\" -u ashipunova -h newbpcdb2 env454 > $out_file" >> $file_name.out_db.$file_number.job.sh
    chmod u+x $file_name.out_db.$file_number.job.sh
    
}

upload_data()
{
    upload_cmd="LOAD DATA LOCAL INFILE '$out_file' INTO TABLE $target_table_name FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES ($column_names)"
    echo "#! /bin/bash" > $file_name.in_db.$file_number.job.sh
    echo "time mysql -e \"$upload_cmd\"  -u ashipunova -h vampsdev vamps2" >> $file_name.in_db.$file_number.job.sh
    chmod u+x $file_name.in_db.$file_number.job.sh
    # too slow, run parallel on a cluster, see make_sge_script
    # mysql -e "$upload_cmd"  -u ashipunova -h vampsdev vamps2
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
#$ -M ashipunova@mbl.edu
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
  while [  $reads_left -gt 0 ]; do
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
