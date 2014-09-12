#! /bioware/python-2.7.5/bin/python

import os
import sys
from time import time
import subprocess
#from subprocess import Popen, PIPE
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
    
def uniq_count(data):
    # print "=-" * 50
    # print data
    result = {}
    result = dict((i, data.count(i)) for i in data)
    return result
    
def remove_size(str):
    try:
    	return str.replace(";size=", "")
    except:
        print "UUU Unexpected error:", sys.exc_info()[0]

	raise	

def frequency_count(chimeric_file_name):
    frequencies = []
    try:
	#print "HHH chimeric_file_name = %s" % chimeric_file_name
        [frequencies.append(line.split("|")[-1].rstrip().split(":")[-1]) for line in open(chimeric_file_name).readlines() if line.startswith('>')]
        freq_dict = uniq_count(frequencies)
        #print "FFF frequencies = %s" % frequencies
	#for key, val in freq_dict.iteritems():
	#	print "freq_dict.iteritems: key = %s, val = %s" % (key, val)
        #        print "DDD freq_dict.iteritems: remove_size(key) = %s, val = %s" % (remove_size(key), val)
        sorted_freq = (sorted((int(remove_size(key)), val) for key, val in freq_dict.iteritems())) 
        return sorted_freq   
    except:
        print "+-" * 50
        print "Unexpected error:", sys.exc_info()[0]
        raise

def print_put(file_basename, all_lines, ref_lines, denovo_lines, ratio, percent_ref, percent_denovo, freq_ref, freq_denovo):
    print "=" * 50

    print file_basename
    # print "all_lines_file_name = %s, ref_lines_file_name = %s, denovo_lines_file_name = %s" % (all_lines_file_name, ref_lines_file_name, denovo_lines_file_name)
    print "all_lines = %s, Chimeric ref = %s, Chimeric denovo = %s" % (all_lines, ref_lines, denovo_lines)
    print "ratio = %s" % ratio 
    print "percent ref = %s, percent denovo = %s" % (percent_ref, percent_denovo)

    # --- print frequencies ----
    print "Frequencies for ref: "
    print "%-10s:  %s" % ("Seq frequency", "Chimeras found")

    for tup in freq_ref:
        print "%-10s: %s" % (tup[0], tup[1])

    print "Frequencies for denovo: "
    print "%-10s:  %s" % ("Seq frequency", "Chimeras found")
    # print freq_denovo
    for tup in freq_denovo:
        print "%-10s: %s" % (tup[0], tup[1])

""" ============ main ============ """
# start = time()

current_dir    = os.getcwd()
print current_dir

filenames = get_basenames(get_file_names(current_dir))

for file_basename in filenames:
    print file_basename
    all_lines      = 0
    ref_lines      = 0
    denovo_lines   = 0
    ratio          = 0
    percent_ref    = 0
    percent_denovo = 0
    freq_ref       = [(0, 0)]
    freq_denovo    = [(0, 0)]
    
    all_lines_file_name    = file_basename + all_lines_suffix
    ref_lines_file_name    = file_basename + chimera_ref_suffix
    denovo_lines_file_name = file_basename + chimera_denovo_suffix
    freq_ref               = frequency_count(ref_lines_file_name)
    
    all_lines      = int(wccount(all_lines_file_name) or 0)
    ref_lines      = int(get_fa_lines_count(ref_lines_file_name) or 0)
    denovo_lines   = int(get_fa_lines_count(denovo_lines_file_name) or 0)
    percent_ref    = percent_count(all_lines, ref_lines)
    percent_denovo = percent_count(all_lines, denovo_lines)

    if (denovo_lines > 0):
        ratio       = count_ratio(ref_lines, denovo_lines)
        
    if (percent_ref > 0):
        freq_denovo = frequency_count(denovo_lines_file_name)

    print_put(file_basename, all_lines, ref_lines, denovo_lines, ratio, percent_ref, percent_denovo, freq_ref, freq_denovo)
        
# elapsed = (time() - start)
# print elapsed

