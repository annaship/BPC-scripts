#!/bin/bash

title="Illumina gast. Run on any cluster."
prompt="Please select a file name pattern:"
#options=("*.unique.nonchimeric.fa" "*.unique.nonchimeric.fa for Fungi (ITS1)" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaeae" "*MAX-MISMATCH-3.unique")
options=("*.unique.nonchimeric.fa v4v5" "*.unique.nonchimeric.fa Euk v4" "*.unique.nonchimeric.fa Fungi ITS1" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaeae" "*MAX-MISMATCH-3.unique" "*.fa non_standard")

echo "$title"
PS3="$prompt "
MORE_OPTIONS=""
select opt in "${options[@]}"; do 

    case "$REPLY" in

#    "*.unique.nonchimeric.fa" )   NAME_PAT=$REPLY; UDB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa v4v5" )   NAME_PAT="*.unique.nonchimeric.fa"; UDB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa Euk v4" )   NAME_PAT="*.unique.nonchimeric.fa"; UDB_NAME=refv4e; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa Fungi ITS1" )   NAME_PAT="*.unique.nonchimeric.fa"; UDB_NAME=refits1; MORE_OPTIONS=" -full -ignoregaps "; echo "You picked option $REPLY"; break;;
    "*-PERFECT_reads.fa.unique" ) NAME_PAT=$REPLY; UDB_NAME=refv6;   echo "You picked option $REPLY"; break;;
    "*-PERFECT_reads.fa.unique for Archaeae" ) NAME_PAT="*-PERFECT_reads.fa.unique"; UDB_NAME=refv6a;   echo "You picked option $REPLY"; break;;
    "*MAX-MISMATCH-3.unique" ) NAME_PAT=$REPLY; UDB_NAME=refv6long;   echo "You picked option $REPLY"; break;;

    1 ) NAME_PAT="*.unique.nonchimeric.fa";        UDB_NAME=refv4v5; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    2 ) NAME_PAT="*.unique.nonchimeric.fa";        UDB_NAME=refv4e; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    3 ) NAME_PAT="*.unique.nonchimeric.fa";        UDB_NAME=refits1; MORE_OPTIONS=" -full -ignoregaps "; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    4 ) NAME_PAT=${options[3]};                    UDB_NAME=refv6; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    5 ) NAME_PAT="*-PERFECT_reads.fa.unique";      UDB_NAME=refv6a; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    6 ) NAME_PAT=${options[5]};                    UDB_NAME=refv6long; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    7 ) NAME_PAT=${options[6]};                    UDB_NAME=non_standard; MORE_OPTIONS=" -full "; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;


    # $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one."; continue;;

    esac

done

echo "UDB_NAME = $UDB_NAME.fa"
echo "MORE_OPTIONS = $MORE_OPTIONS"
echo "NAME_PAT = $NAME_PAT"
echo "Files number: = `echo $NAME_PAT | wc -w`"

for file in $NAME_PAT

do
  echo "============="
  #echo $file
  echo "clusterize /bioware/seqinfo/bin/gast_ill -saveuc -nodup $MORE_OPTIONS -in $file -db /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.fa -rtax /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.tax -out $file.gast"
  clusterize /bioware/seqinfo/bin/gast_ill -saveuc -nodup $MORE_OPTIONS -in $file -db /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.fa -rtax /xraid2-2/g454/blastdbs/gast_distributions/$UDB_NAME.tax -out $file.gast

done
