#! /bioware/python-2.7.5/bin/python

import os
import sys
from time import time
import subprocess
import difflib

base_suffix = "MERGED-MAX-MISMATCH-3"
unique_suffix = ".unique"
nochimeric_suffix = ".unique.nonchimeric.fa"

def get_file_names(current_dir):
    files = []
    for (dirpath, dirname, filenames) in os.walk(current_dir):
        files.extend(filenames)
        break
    return files
    
def get_basenames(filenames):
    file_basenames = set()
    for f in filenames:
        file_basename = f.split(".")[0]
        if file_basename.endswith(base_suffix):
            file_basenames.add(file_basename)
        else:
            next

    return file_basenames

def wccount(filename):
    return subprocess.check_output(['wc', '-l', filename]).split()[0]

def get_diff(unique_file_name, nochimeric_file_name):
    file1 = open(unique_file_name, 'r')
    file2 = open(nochimeric_file_name, 'r')
    file1_content = [l for l in file1.readlines() if l.startswith('>')]
    file2_content = [l for l in file2.readlines() if l.startswith('>')]
    only_in_chimeric = []
    
    diff = difflib.ndiff(file1_content, file2_content)
    only_in_chimeric.append(x[2:] for x in diff if (x.startswith('- ')))

    return only_in_chimeric

def get_size(only_in_chimeric):
    size_chim = 0
    for diff_next in only_in_chimeric:  
      try:
          while 1:
              # print diff_next.next()
              size_chim += int(diff_next.next().split(':')[-1])
      except:
          pass
    return size_chim
    
    

""" ============ main ============ """

current_dir    = os.getcwd()
print current_dir

before_file_suffix = "_MERGED-MAX-MISMATCH-3.unique"
after_file_suffix = "_MERGED-MAX-MISMATCH-3.unique.nonchimeric.fa"

filenames = get_basenames(get_file_names(current_dir))

for file_basename in filenames:
    before_reads = 0
    after_reads = 0
    unique_file_name = file_basename + unique_suffix
    nochimeric_file_name = file_basename + nochimeric_suffix

    only_in_chimeric = get_diff(unique_file_name, nochimeric_file_name)
    size = get_size(only_in_chimeric)

    print "-" * 10
    print file_basename
    print "Total amount of not unique seq: %s" % wccount(file_basename)
    print "Lost to chimeras: %s" % size
    
# todo:
# benchmark count all in not uniq and sum all of sizes notchimeric and get the difference

