#!/bin/bash

title="Merging files with merge-illumina-pairs one by one, to run in parallel use run_v4v5_merge_on_cluster.sh"
prompt="Please select a dna region:"
options=("v4v5" "ITS1")

echo "$title"
PS3="$prompt "
select opt in "${options[@]}"; do 

    case "$REPLY" in

    "v4v5" ) DNA_REGION=$REPLY;        ADD_ARG="";                          echo "You picked option 'v4v5'"; break;;
    "ITS1" ) DNA_REGION=$REPLY;        ADD_ARG=" --marker-gene-stringent "; echo "You picked option 'ITS1'"; break;;
    1 )      DNA_REGION=${options[0]}; ADD_ARG="";                          echo "You picked option 'v4v5'"; break;;
    2 )      DNA_REGION=${options[1]}; ADD_ARG=" --marker-gene-stringent "; echo "You picked option 'ITS1'"; break;;

    *) echo "Invalid option. Try another one."; continue;;

    esac

done

for fullfile in *.ini
do
  echo "============="
  echo $fullfile
  echo "merge-illumina-pairs --enforce-Q30-check $ADD_ARG $fullfile"
  merge-illumina-pairs --enforce-Q30-check $ADD_ARG $fullfile
done
