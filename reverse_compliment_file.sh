#! /bin/bash
# $1 - file name
# example: 
# bash-3.2$ echo "ATCG" >temp.1
# bash-3.2$ ./reverse_compliment.sh temp.1

if [[ $# == 0 ]] || [[ $1 == "-h" ]]
then
  echo "Usage: $0 seq_file_name"
else
  rev $1 | tr "T" "1" | tr "A" "2" | tr "C" "3" | tr "G" "4" | tr "1" "A" | tr "2" "T" | tr "3" "G" | tr "4" "C"
fi
