#! /bin/bash
# -- For Ion Torrent sff files.
# -- Separates and create new sff files by run prefix.
# -- If rundate is given as a parameter --- runs raw sequence upload.


PARAM_NUM=$#
RUNDATE=$@
echo "$PARAM_NUM parameters"; 
echo "rundate = $RUNDATE";

# LSM_071007_st2.sff
# LSM_071007_st3.sff
# LSM_071007_st4.sff
# LSM_071007_st5.sff
# LSM_080707_st2.sff
# LSM_080707_st3.sff
# LSM_080707_st4.sff
# LSM_080707_st5.sff

# -- For each sff file get all "read_ids" --
FILES=`ls | grep "\.sff$"`
echo "FILES = $FILES"
for f in $FILES
do
  # filename=$(basename $f)
  # extension=${filename##*.}
  # filename=${filename%.*}
  # echo "filename = $filename"
  echo "filename = $f"
  sffinfo -a -t $f > ${f}_read_ids.txt
done

# -- Combine all "read_ids" into one file --
cat *\.sff_read_ids\.txt > all_read_ids.txt

rm *\.sff_read_ids\.txt

# -- Separate read_ids by run_prefix (314 vs. 316 runs?) 
# -- and 
# -- use read_id list to create new sff files --
RUN_PREFIX=`awk '{FS=":"; print $1}' <all_read_ids.txt | sort -u | sed '/^.*:.*$/ d'` #sed is needed because the first line keeps colon
echo $RUN_PREFIX
for r in $RUN_PREFIX
do
  echo "HERE $r"
  grep $r < all_read_ids.txt > read_ids_${r}.txt
  echo "FILES = $FILES"
  NEWFILENAME=${r}.sff
  sfffile -o $NEWFILENAME -i read_ids_${r}.txt $FILES  
  echo "Writing the sff.txt file..."
  sffinfo -t $NEWFILENAME > ${NEWFILENAME}.txt  
  # change ":" in read_ids with "_"
  sed 's/^>\([^:]*\):\([^:]*\):\([^:]*\)/>\1_\2_\3/' < ${NEWFILENAME}.txt > ${NEWFILENAME}.$$
  mv ${NEWFILENAME}.$$ ${NEWFILENAME}.txt
  # for f in $FILES
  # do 
  #   echo "HERE1 $f"
  #   NEWFILENAME=${r}_${f}
  #   echo "\${NEWFILENAME} = ${NEWFILENAME}"
  #   sfffile -o ${NEWFILENAME} -i read_ids_${r}.txt $f    
  #   # create sff.txt files
  #   sffinfo -t ${NEWFILENAME} > ${NEWFILENAME}.txt
  #   # change ":" in read_ids with "_"
  #   sed 's/^>\([^:]*\):\([^:]*\):\([^:]*\)/>\1_\2_\3/' < ${NEWFILENAME}.txt > ${NEWFILENAME}.$$
  #   mv ${NEWFILENAME}.$$ ${NEWFILENAME}.txt
  #   # run raw sequence upload if rundate is specified
  #   if [ "$PARAM_NUM" -eq 1 ]
  #   then 
  #       echo "PARAM_NUM equals 1"
  #       time import_flxrun -skipsff -r $RUNDATE -i ${NEWFILENAME}
  #   fi    
  # done  
done
