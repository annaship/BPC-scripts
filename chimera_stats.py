#! /bioware/python-2.7.2/bin/python

import os
import sys
from time import time
import subprocess
sys.path.append("/xraid/bioware/linux/seqinfo/bin")
sys.path.append("/Users/ashipunova/bin/illumina-utils")
sys.path.append("/Users/ashipunova/bin/illumina-utils/illumina-utils/scripts")
sys.path.append("/bioware/merens-illumina-utils")

# import fastalib as fa

all_lines_suffix      = ".txt" # or ".db, doesn't matter"
chimera_ref_suffix    = ".db.chimeric.fa"
chimera_denovo_suffix = ".txt.chimeric.fa"
base_suffix           = "unique.chimeras"

def get_file_names(current_dir):
    files = []
    for (dirpath, dirname, filenames) in os.walk(current_dir):
        files.extend(filenames)
        break
    return files
    
def get_basenames(filenames):
    file_basenames = set()
    for f in filenames:
        file_basename = ".".join(f.split(".")[0:3])
        if file_basename.endswith(base_suffix):
            file_basenames.add(file_basename)

    return file_basenames

def wccount(filename):
    return subprocess.check_output(['wc', '-l', filename]).split()[0]

def count_ratio(ref_num, denovo_num):
    return float(ref_num) / float(denovo_num) 

def get_fa_lines_count(file_name):
    # return fa.SequenceSource(file_name, lazy_init = False).total_seq
    file_open = open(file_name)
    return len([l for l in file_open.readlines() if l.startswith('>')])

def percent_count(all_lines, chimeric_count):
    return float(chimeric_count) * 100 / float(all_lines)

""" ============ main ============ """
# start = time()

current_dir = os.getcwd()
print current_dir

filenames = get_basenames(get_file_names(current_dir))

for file_basename in filenames:

    all_lines_file_name    = file_basename + all_lines_suffix
    ref_lines_file_name    = file_basename + chimera_ref_suffix
    denovo_lines_file_name = file_basename + chimera_denovo_suffix

    all_lines    = wccount(all_lines_file_name)
    ref_lines    = get_fa_lines_count(ref_lines_file_name)
    denovo_lines = get_fa_lines_count(denovo_lines_file_name)

    
    ratio = count_ratio(ref_lines, denovo_lines)

    percent_ref    = percent_count(all_lines, ref_lines)
    percent_denovo = percent_count(all_lines, denovo_lines)


    if (int(percent_ref) > 15):
        print "="*50
        
        print file_basename
        # print "all_lines_file_name = %s, ref_lines_file_name = %s, denovo_lines_file_name = %s" % (all_lines_file_name, ref_lines_file_name, denovo_lines_file_name)
        print "all_lines = %s, ref_lines = %s, denovo_lines = %s" % (all_lines, ref_lines, denovo_lines)
        print "ratio = %s" % ratio 
        print "percent_ref = %s, percent_denovo = %s" % (percent_ref, percent_denovo)
    
# elapsed = (time() - start)
# print elapsed
