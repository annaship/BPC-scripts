#!/bin/bash

title="Illumina gast. Run on grendel."
prompt="Please select a file name pattern:"
#options=("*.unique.nonchimeric.fa" "*.unique.nonchimeric.fa for Fungi (ITS1)" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaeae" "*MAX-MISMATCH-3.unique")
options=("*.unique.nonchimeric.fa v4v5" "*.unique.nonchimeric.fa Euk v4" "*.unique.nonchimeric.fa Fungi ITS1" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaeae" "*MAX-MISMATCH-3.unique")

echo "$title"
PS3="$prompt "
ITS_OPTION=""
select opt in "${options[@]}"; do 

    case "$REPLY" in

#    "*.unique.nonchimeric.fa" )   NAME_PAT=$REPLY; UDB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa v4v5" )   NAME_PAT="*.unique.nonchimeric.fa"; UDB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa Euk v4" )   NAME_PAT="*.unique.nonchimeric.fa"; UDB_NAME=refv4e; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa Fungi ITS1" )   NAME_PAT="*.unique.nonchimeric.fa"; UDB_NAME=refits1; ITS_OPTION=" -full "; echo "You picked option $REPLY"; break;;
    "*-PERFECT_reads.fa.unique" ) NAME_PAT=$REPLY; UDB_NAME=refv6;   echo "You picked option $REPLY"; break;;
    "*-PERFECT_reads.fa.unique for Archaeae" ) NAME_PAT="*-PERFECT_reads.fa.unique"; UDB_NAME=refv6a;   echo "You picked option $REPLY"; break;;
    "*MAX-MISMATCH-3.unique" ) NAME_PAT=$REPLY; UDB_NAME=refv6long;   echo "You picked option $REPLY"; break;;

    1 ) NAME_PAT="*.unique.nonchimeric.fa";        UDB_NAME=refv4v5; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    2 ) NAME_PAT="*.unique.nonchimeric.fa";        UDB_NAME=refv4e; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    3 ) NAME_PAT="*.unique.nonchimeric.fa";        UDB_NAME=refits1; ITS_OPTION=" -full "; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    4 ) NAME_PAT=${options[3]};                    UDB_NAME=refv6; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    5 ) NAME_PAT="*-PERFECT_reads.fa.unique";      UDB_NAME=refv6a; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;
    6 ) NAME_PAT=${options[5]};                    UDB_NAME=refv6long; echo "You picked option $REPLY, ref file $UDB_NAME"; break;;

    # $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one."; continue;;

    esac

done

echo "UDB_NAME = $UDB_NAME.udb"
echo "ITS_OPTION = $ITS_OPTION"
echo "NAME_PAT = $NAME_PAT"
echo "Files number: = `echo $NAME_PAT | wc -w`"

for file in ../$NAME_PAT
do
  file_name=$(basename $file)
  echo "============="
  #echo $file
  echo "clusterize /bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in $file -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out ${PWD}/$file_name.gast"
  clusterize /bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in $file -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out ${PWD}/$file_name.gast

done
