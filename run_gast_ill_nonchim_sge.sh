#!/bin/bash
# -vx

function verbose_log () {
    if [[ $verbosity -eq 1 ]]; then
        echo "$@"
    fi
}

USAGE="Illumina gast. Run on grendel. Optional arguments: [-d gast output directory (default: analysis/gast)] [-s script name] [-g path to gast ref files (default: /xraid2-2/g454/blastdbs/gast_distributions)] [-v verbosity (default: 0)] [-h this statement]"

# [-t vsearch threads (default: 0)] - removed Tue Nov 28 2017 by Rich's request, ASh

# args
# DEFAULT
gast_dir="../gast"
# RUN_LANE="RUN_LANE"
RUN_LANE=`pwd | sed 's,^/xraid2-2/g454/run_new_pipeline/illumina/\(.*\)/\(lane_1_[^/]*\)/.*,\1_\2,g' | sed 's#/#_#g'`

# threads="0"
gast_db_path="/xraid2-2/g454/blastdbs/gast_distributions"
verbosity=0

add_options='d:s:t:g:vh'
while getopts $add_options add_option
do
    case $add_option in
        d  )    gast_dir=$OPTARG;;
        s  )    RUN_LANE=$OPTARG;;
        # t  )    threads=$OPTARG;;
        g  )    gast_db_path=$OPTARG;;
        v  )    verbosity=1;;
        h  )    echo $USAGE; exit;;
        \? )    if (( (err & ERROPTS) != ERROPTS ))
                then
                    error $NOEXIT $ERROPTS "Unknown option."
                fi;;
        *  )    error $NOEXIT $ERROARG "Missing option argument.";;
    esac
done

shift $(($OPTIND - 1))

printf "%s %d\n" "Verbosity level set to:" "$verbosity"

title="Illumina gast. Run on grendel."
prompt="Please select a file name pattern:"
options=("*.unique.nonchimeric.fa v4v5" "*.unique.nonchimeric.fa v4v5a for Archaea" "*.unique.nonchimeric.fa v4" "*.unique.nonchimeric.fa Euk v4" "*.unique.nonchimeric.fa Fungi ITS1" "*.unique v6" "*.unique v6 for Archaea" "*MAX-MISMATCH-3.unique.nonchimeric.fa full length")

echo "$title"
PS3="$prompt "
MORE_OPTIONS=""

verbose_log "gast_dir = $gast_dir"
verbose_log "RUN_LANE = $RUN_LANE"
# verbose_log "threads  = $threads"
verbose_log "gast_db_path = $gast_db_path"

select opt in "${options[@]}"; do 

    case "$REPLY" in

    "*.unique.nonchimeric.fa v4v5" )   NAME_PAT="*.unique.nonchimeric.fa"; REF_DB_NAME=refv4v5; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa v4v5a for Archaea" )   NAME_PAT="*.unique.nonchimeric.fa"; REF_DB_NAME=refv4v5a; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa v4" )   NAME_PAT="*.unique.nonchimeric.fa"; REF_DB_NAME=refv4; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa Euk v4" )   NAME_PAT="*.unique.nonchimeric.fa"; REF_DB_NAME=refv4e; echo "You picked option $REPLY"; break;;
    "*.unique.nonchimeric.fa Fungi ITS1" )   NAME_PAT="*.unique.nonchimeric.fa"; REF_DB_NAME=refits1; MORE_OPTIONS=" -full -ignoregaps "; echo "You picked option $REPLY"; break;;
    "*.unique v6" ) NAME_PAT=$REPLY; REF_DB_NAME=refv6;   echo "You picked option $REPLY"; break;;
    "*.unique v6 for Archaea" ) NAME_PAT="*.unique"; REF_DB_NAME=refv6a;   echo "You picked option $REPLY"; break;;
    "*MAX-MISMATCH-3.unique.nonchimeric.fa full length" ) NAME_PAT=$REPLY; REF_DB_NAME=refssu; MORE_OPTIONS=" -full ";  echo "You picked option $REPLY"; break;;

    1 ) NAME_PAT="*.unique.nonchimeric.fa";        REF_DB_NAME=refv4v5; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;
    2 ) NAME_PAT="*.unique.nonchimeric.fa";        REF_DB_NAME=refv4v5a; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;
    3 ) NAME_PAT="*.unique.nonchimeric.fa";        REF_DB_NAME=refv4; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;    
    4 ) NAME_PAT="*.unique.nonchimeric.fa";        REF_DB_NAME=refv4e; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;
    5 ) NAME_PAT="*.unique.nonchimeric.fa";        REF_DB_NAME=refits1; MORE_OPTIONS=" -full -ignoregaps "; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;
    6 ) NAME_PAT="*.unique";      REF_DB_NAME=refv6; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;
    7 ) NAME_PAT="*.unique";      REF_DB_NAME=refv6a; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;
    8 ) NAME_PAT="*.unique.nonchimeric.fa";                    REF_DB_NAME=refssu; MORE_OPTIONS=" -full "; echo "You picked option $REPLY, ref file $REF_DB_NAME"; break;;

    # $(( ${#options[@]}+1 )) ) echo "Goodbye!"; break;;
    *) echo "Invalid option. Try another one."; continue;;

    esac

done

verbose_log "REF_DB_NAME = $REF_DB_NAME.fa"
verbose_log "MORE_OPTIONS = $MORE_OPTIONS"
verbose_log "NAME_PAT = $NAME_PAT"

# gunzip first!
# gunzip *MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa.gz
DIRECTORY_NAME=`pwd`

mkdir $gast_dir
ls $NAME_PAT >$gast_dir/filenames.list

cd $gast_dir

FILE_NUMBER=`wc -l < filenames.list`
echo "total files = $FILE_NUMBER"

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
# Send mail; -m as sends on abort, suspend.
#$ -m as
#$ -t 1-$FILE_NUMBER
# Now the script will iterate $FILE_NUMBER times.

  . /xraid/bioware/Modules/etc/profile.modules
  module load bioware
  module load vsearch

  LISTFILE=./filenames.list
  INFILE=\`sed -n "\${SGE_TASK_ID}p" \$LISTFILE\`
  echo "====="
  echo "file name is \$INFILE"
  echo

  echo "/bioware/seqinfo/bin/gast_ill -saveuc -nodup $MORE_OPTIONS -in $DIRECTORY_NAME/\$INFILE -db $gast_db_path/$REF_DB_NAME.fa -rtax $gast_db_path/$REF_DB_NAME.tax -out $DIRECTORY_NAME/$gast_dir/\$INFILE.gast -uc $DIRECTORY_NAME/$gast_dir/\$INFILE.uc"

  /bioware/seqinfo/bin/gast_ill -saveuc -nodup $MORE_OPTIONS -in $DIRECTORY_NAME/\$INFILE -db $gast_db_path/$REF_DB_NAME.fa -rtax $gast_db_path/$REF_DB_NAME.tax -out $DIRECTORY_NAME/$gast_dir/\$INFILE.gast -uc $DIRECTORY_NAME/$gast_dir/\$INFILE.uc
  
  chmod 666 clust_gast_ill_$RUN_LANE.sh.sge_script.sh.log
  
InputComesFromHERE

echo "Running clust_gast_ill_$RUN_LANE.sh"
qsub clust_gast_ill_$RUN_LANE.sh
