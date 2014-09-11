#!/bin/bash

chimera_db_stats.sh | sort -n -k 7
echo "========"
chimera_denovo_stats.sh | sort -n -k 7
