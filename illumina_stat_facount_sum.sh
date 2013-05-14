#!/bin/bash
# count facount sum for all not empty "PERFECT_reads.fa.unique" files

ls -l | awk '{if($4 !~ /0/) print $9}' | grep -v ".ini" | grep "PERFECT_reads.fa.unique$" |  xargs facount | awk '{s+=$0} END {print s}'

