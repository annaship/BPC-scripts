#!/bin/bash

USAGE="Illumina gast. Run on grendel. Optional arguments: [-d gast output directory] [-r script name]"

# args
gast_dir="gast_silva119"
# RUN_LANE="RUN_LANE"
RUN_LANE=`pwd | sed 's,^/xraid2-2/g454/run_new_pipeline/illumina/\(.*\)/\(lane_1_[^/]*\)/.*,\1_\2,g'`

add_options='d:s:h'
while getopts $add_options add_option
do
    case $add_option in
        d  )    gast_dir=$OPTARG;;
        s  )    RUN_LANE=$OPTARG;;
        h  )    echo $USAGE; exit;;
        \? )    if (( (err & ERROPTS) != ERROPTS ))
                then
                    error $NOEXIT $ERROPTS "Unknown option."
                fi;;
        *  )    error $NOEXIT $ERROARG "Missing option argument.";;
    esac
done

shift $(($OPTIND - 1))

title="Illumina gast. Run on grendel."
prompt="Please select a file name pattern:"
#options=("*.unique.nonchimeric.fa" "*.unique.nonchimeric.fa for Fungi (ITS1)" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaeae" "*MAX-MISMATCH-3.unique")
options=("*.unique.nonchimeric.fa v4v5" "*.unique.nonchimeric.fa Euk v4" "*.unique.nonchimeric.fa Fungi ITS1" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaeae" "*MAX-MISMATCH-3.unique")

echo "$title"
PS3="$prompt "
ITS_OPTION=""
echo "gast_dir = $gast_dir"
echo "RUN_LANE = $RUN_LANE"


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

# gunzip first!
# gunzip *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa.gz
DIRECTORY_NAME=`pwd`

mkdir $gast_dir
ls *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa >$gast_dir/nonchimeric_files.list

cd $gast_dir

FILE_NUMBER=`wc -l < nonchimeric_files.list`
echo "total files = $FILE_NUMBER"
# NAME_PAT="*.unique.nonchimeric.fa"
# UDB_NAME="refv4v5"
# ITS_OPTION=""

cat >clust_gast_ill_$RUN_LANE.sh <<InputComesFromHERE
#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N clust_gast_ill_$RUN_LANE.sh
# Giving the name of the output log file
#$ -o clust_gast_ill_$RUN_LANE.sh.sge_script.sh.log
# Combining output/error messages into one file
#$ -j y
# Send mail to these users
#$ -M ashipunova@mbl.edu
# Send mail at job end; -m eas sends on end, abort, suspend.
#$ -m eas
#$ -t 1-$FILE_NUMBER
# Now the script will iterate $FILE_NUMBER times.

  . /xraid/bioware/Modules/etc/profile.modules
  module load bioware

  LISTFILE=./nonchimeric_files.list
  INFILE=\`sed -n "\${SGE_TASK_ID}p" \$LISTFILE\`
  echo "file name is \$INFILE"

  echo "/bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in $DIRECTORY_NAME/\$INFILE -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out $DIRECTORY_NAME/$gast_dir/\$INFILE.gast -uc $DIRECTORY_NAME/$gast_dir/\$INFILE.uc"

  # /bioware/seqinfo/bin/gast_ill -saveuc -nodup $ITS_OPTION -in $DIRECTORY_NAME/\$INFILE -db /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.fa -rtax /workspace/ashipunova/silva/119/regast/gast_distributions_119/$UDB_NAME.tax -out $DIRECTORY_NAME/$gast_dir/\$INFILE.gast -uc $DIRECTORY_NAME/$gast_dir/\$INFILE.uc

InputComesFromHERE

chmod a+x clust_gast_ill_$RUN_LANE.sh 
echo "Running clust_gast_ill_$RUN_LANE.sh"
qsub $DIRECTORY_NAME/$gast_dir/clust_gast_ill_$RUN_LANE.sh