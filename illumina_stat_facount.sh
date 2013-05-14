#!/bin/bash
# prints file name and facount for all not empty perfect reads files

ls -l | awk '{if($4 !~ /0/) print $9}' | grep -v ".ini" | grep "PERFECT_reads.fa.unique$" |  xargs illumina_stat_facount_add.sh

