#! /bin/bash
for file in IDX*.fastq.gz; do ind=`gzip -cd $file | head -1 | cut -d":" -f10`; mv $file $ind"_"$file;  done

