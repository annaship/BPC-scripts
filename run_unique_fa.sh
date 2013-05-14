#!/bin/bash

title="Uniqueing fasta files. Run on grendel."
prompt="Please select a file name pattern:"
options=("*_MERGED_FILTERED" "*-PERFECT_reads.fa")

echo "$title"
PS3="$prompt "
select opt in "${options[@]}"; do 

    case "$REPLY" in

    "*_MERGED_FILTERED.unique" )           NAME_PAT=$REPLY; echo "You picked option $REPLY"; break;;
    "*-PERFECT_reads.fa.unique" ) NAME_PAT=$REPLY; echo "You picked option $REPLY"; break;;
    1 ) NAME_PAT=${options[0]};                    echo "You picked option $REPLY"; break;;
    2 ) NAME_PAT=${options[1]};                    echo "You picked option $REPLY"; break;;

    # $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one."; continue;;

    esac

done

for file in $NAME_PAT
do
  echo "============="
  echo $file
  clusterize /bioware/seqinfo/bin/fastaunique $file
done

