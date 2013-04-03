#!/bin/bash

title="Illumina gast. Run on grendel."
prompt="Please select a file name pattern:"
options=("*_MERGED.unique" "*-PERFECT_reads.fa.unique")

echo "$title"
PS3="$prompt "
select opt in "${options[@]}"; do 

    case "$REPLY" in

    "*_MERGED.unique" )           NAME_PAT=$REPLY; UDB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    "*-PERFECT_reads.fa.unique" ) NAME_PAT=$REPLY; UDB_NAME=refv6;   echo "You picked option $REPLY"; break;;
    1 ) NAME_PAT=${options[0]};                    UDB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    2 ) NAME_PAT=${options[1]};                    UDB_NAME=refv6; echo "You picked option $REPLY"; break;;

    # $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one."; continue;;

    esac

done

echo "UDB_NAME = $UDB_NAME.udb"
for file in $NAME_PAT
do
  echo "============="
  echo $file
  clusterize /bioware/seqinfo/bin/gast_ill -saveuc -nodup  -in $file -db /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.udb -rtax /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.tax -out $file.gast
done
