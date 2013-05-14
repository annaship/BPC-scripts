#!/bin/bash
#combine stats for all not empty files

ls -l | awk '{if($4 !~ /0/) print $9}' | grep -v ".ini" | grep STATS | xargs head

