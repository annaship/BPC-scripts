#!/bin/bash

echo "This will run the merge script for v4v5 or ITS1 in parallel jobs on a cluster"
merge_clusterize.sh
qsub merge_clusterize.sh.sge_script.sh

