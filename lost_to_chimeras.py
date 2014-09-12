#! /bioware/python-2.7.5/bin/python

import os
import sys
from time import time
import subprocess
import difflib

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

def get_head_lines(file_basename):
    file_open = open(file_basename, 'r')
    return  [l for l in file_open.readlines() if l.startswith('>')]

def get_diff(file1_content, file2_content):
    only_not_chimeric = []
    
    diff = difflib.ndiff(file1_content, file2_content)
    """ '- ' 	line unique to file1_content """
    only_not_chimeric.append(x[2:] for x in diff if (x.startswith('- ')))

    return only_not_chimeric

def get_size(only_not_chimeric):
    size_chim = 0
    for diff_next in only_not_chimeric:  
      try:
          while 1:
              size_chim += int(diff_next.next().split(':')[-1])
      except:
          pass
    return size_chim    
    
def get_percent(before_chim, chim_size):
  return float(chim_size) * 100 / float(before_chim)
  

""" ============ main ============ """

current_dir    = os.getcwd()
print current_dir

base_suffix = "MERGED-MAX-MISMATCH-3"
unique_suffix = ".unique"
nochimeric_suffix = ".unique.nonchimeric.fa"

filenames = get_basenames(get_file_names(current_dir))

for file_basename in filenames:
    unique_file_name = file_basename + unique_suffix
    nochimeric_file_name = file_basename + nochimeric_suffix

    only_not_chimeric = get_diff(get_head_lines(unique_file_name), get_head_lines(nochimeric_file_name))
    chim_size = get_size(only_not_chimeric)
    before_chim =  wccount(file_basename)
    perc = get_percent(before_chim, chim_size)
    
    print "-" * 10
    print file_basename
    print "Total amount of not unique seq: %s" % before_chim
    print "Lost to chimeras: %s" % chim_size
    print "Lost to chimeras (percentage): %s" % round(perc, 2)
