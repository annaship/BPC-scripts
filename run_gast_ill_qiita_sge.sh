#!/bin/bash
# -vx

function verbose_log () {
    if [[ $verbosity -eq 1 ]]; then
        echo "$@"
    fi
}

USAGE="Illumina gast. Run on grendel. Optional arguments: [-d gast output directory (default: analysis/gast)] [-s script name] [-g path to gast ref files (default: /xraid2-2/g454/blastdbs/gast_distributions)] [-t vsearch threads (default: 0)] [-v verbosity (default: 0)] [-e processing filename extension] [-r reference database filename] [-p strand plus/both (default: plus)] [-f full sequence references (default: 0)] [-i use ignoregaps (default: yes = 1)] [-h this statement]"

# args
# DEFAULTS

gast_dir="../gast"
# RUN_LANE=`date`
RUN_LANE=`echo "$[ 1 + $[ RANDOM % 1000 ]]"`
threads="0"
gast_db_path="/xraid2-2/g454/blastdbs/gast_distributions"
verbosity=0
full_ref=0
ignoregaps=1
strand="plus"

add_options='d:s:t:g:e:r:i:p:fvh'
while getopts $add_options add_option
do
    case $add_option in
        d  )    gast_dir=$OPTARG;;
        s  )    RUN_LANE=$OPTARG;;
        t  )    threads=$OPTARG;;
        g  )    gast_db_path=$OPTARG;;
        e  )    file_ext=$OPTARG;;
        r  )    ref_db=$OPTARG;;
        p  )    strand=$OPTARG;;
        f  )    full_ref=1;;
        i  )    ignoregaps=$OPTARG;;
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
# prompt="Please select a file name pattern:"
# options=("*.unique.nonchimeric.fa v4v5" "*.unique.nonchimeric.fa v4v5a for Archaea" "*.unique.nonchimeric.fa Euk v4" "*.unique.nonchimeric.fa Fungi ITS1" "*-PERFECT_reads.fa.unique" "*-PERFECT_reads.fa.unique for Archaea" "*MAX-MISMATCH-3.unique.nonchimeric.fa for Av6 mod (long)")

echo "$title"
FULL_OPTION=""
# NAME_PAT="*.unique.nonchimeric.fa";
# REF_DB_NAME=refssu;
REF_DB_NAME=$ref_db
NAME_PAT=*$file_ext

if [[ $full_ref -eq 1 ]]; then
    FULL_OPTION=" -full "
fi

if [[ $ignoregaps -eq 1 ]]; then
    IGNOREGAPS_OPTION=" -ignoregaps "
fi

verbose_log "gast_dir = $gast_dir"
verbose_log "RUN_LANE = $RUN_LANE"
verbose_log "threads  = $threads"
verbose_log "gast_db_path = $gast_db_path"
verbose_log "file_ext = $file_ext"
verbose_log "ref_db = $ref_db"
verbose_log "strand = $strand"


verbose_log "REF_DB_NAME = $ref_db"
verbose_log "FULL_OPTION = $FULL_OPTION"
verbose_log "IGNOREGAPS_OPTION = $IGNOREGAPS_OPTION"
verbose_log "NAME_PAT = $file_ext"

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

  LISTFILE=./filenames.list
  INFILE=\`sed -n "\${SGE_TASK_ID}p" \$LISTFILE\`
  echo "====="
  echo "file name is \$INFILE"
  echo

  echo "/bioware/seqinfo/bin/gast_ill -saveuc -nodup $FULL_OPTION $IGNOREGAPS_OPTION -in $DIRECTORY_NAME/\$INFILE -db $gast_db_path/$REF_DB_NAME.fa -rtax $gast_db_path/$REF_DB_NAME.tax -out $DIRECTORY_NAME/$gast_dir/\$INFILE.gast -uc $DIRECTORY_NAME/$gast_dir/\$INFILE.uc -threads $threads -strand $strand"

  /bioware/seqinfo/bin/gast_ill -saveuc -nodup $FULL_OPTION $IGNOREGAPS_OPTION -in $DIRECTORY_NAME/\$INFILE -db $gast_db_path/$REF_DB_NAME.fa -rtax $gast_db_path/$REF_DB_NAME.tax -out $DIRECTORY_NAME/$gast_dir/\$INFILE.gast -uc $DIRECTORY_NAME/$gast_dir/\$INFILE.uc -threads $threads -strand $strand
  
  chmod 666 clust_gast_ill_$RUN_LANE.sh.sge_script.sh.log
  
InputComesFromHERE

echo "Running clust_gast_ill_$RUN_LANE.sh"
qsub clust_gast_ill_$RUN_LANE.sh

