#! /bin/sh

file_list="$(ls *.ini)"

for f in $file_list
do
FILESIZE=$(wc -l < ${f%.*}"_R1.fastq")
if [ $FILESIZE -gt 0 ]; then
    echo ${f%.*};
    echo $FILESIZE;
    iu-merge-pairs --enforce-Q30-check $f
fi
done