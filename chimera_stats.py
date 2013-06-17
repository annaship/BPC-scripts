#! /bioware/python-2.7.2/bin/python

import os
import sys
from time import time
import subprocess
# sys.path.append("/xraid/bioware/linux/seqinfo/bin")
# sys.path.append("/Users/ashipunova/bin/illumina-utils")
# sys.path.append("/Users/ashipunova/bin/illumina-utils/illumina-utils/scripts")
# sys.path.append("/bioware/merens-illumina-utils")

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
    try:
        return float(ref_num or 0) / float(denovo_num or 0) 
    except ZeroDivisionError:
        # print "There is no denovo chimeras to count ratio."
        pass
    else:
        raise

def get_fa_lines_count(file_name):
    # return fa.SequenceSource(file_name, lazy_init = False).total_seq
    try:
        file_open = open(file_name)
        return len([l for l in file_open.readlines() if l.startswith('>')])
    except IOError, e:
        print e
        return 0
        # print "%s\nThere is no such file: %s" % (e, file_name)
    else:
        raise

def percent_count(all_lines, chimeric_count):
    try:
        return float(chimeric_count or 0) * 100 / float(all_lines or 0)
    except ZeroDivisionError:
        # print "There is no denovo chimeras to count ratio."
        pass
    else:
        raise
    

""" ============ main ============ """
# start = time()

all_lines      = 0
ref_lines      = 0
denovo_lines   = 0
ratio          = 0
percent_ref    = 0
percent_denovo = 0

current_dir    = os.getcwd()
print current_dir

filenames = get_basenames(get_file_names(current_dir))

for file_basename in filenames:
    # print file_basename

    all_lines_file_name    = file_basename + all_lines_suffix
    ref_lines_file_name    = file_basename + chimera_ref_suffix
    denovo_lines_file_name = file_basename + chimera_denovo_suffix

    all_lines    = int(wccount(all_lines_file_name) or 0)
    ref_lines    = int(get_fa_lines_count(ref_lines_file_name) or 0)
    denovo_lines = int(get_fa_lines_count(denovo_lines_file_name) or 0)

    # denovo_lines = int(denovo_lines or 0)


    if (denovo_lines > 0):
    
        ratio          = count_ratio(ref_lines, denovo_lines)

        percent_ref    = percent_count(all_lines, ref_lines)
        percent_denovo = percent_count(all_lines, denovo_lines)
        
        print "type(ratio) = %s" % type(ratio)
        # print "percent_ref = %s, percent_denovo = %s" % (percent_ref, percent_denovo)
        print "type(percent_ref) = %s, type(percent_denovo) = %s" % (type(percent_ref), type(percent_denovo))
        print "type(all_lines) = %s, type(ref_lines) = %s, type(denovo_lines) = %s" % (type(all_lines), type(ref_lines), type(denovo_lines))
        

    # percent_ref = int(percent_ref or 0)
    if (percent_ref > 1):
        print "="*50
        
        print file_basename
        # print "all_lines_file_name = %s, ref_lines_file_name = %s, denovo_lines_file_name = %s" % (all_lines_file_name, ref_lines_file_name, denovo_lines_file_name)
        print "all_lines = %s, ref_lines = %s, denovo_lines = %s" % (all_lines, ref_lines, denovo_lines)
        print "ratio = %s" % ratio 
        print "percent_ref = %s, percent_denovo = %s" % (percent_ref, percent_denovo)
    
# elapsed = (time() - start)
# print elapsed
