#! /bin/sh

file_list="$(ls *.MERGED)"

for f in $file_list
do
    echo "iu-filter-merged-reads $f"
    iu-filter-merged-reads $f

    echo "/usr/local/bin/fastaunique $f"
    /usr/local/bin/fastaunique $f
done