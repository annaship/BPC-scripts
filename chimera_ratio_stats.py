#! /bioware/python-2.7.5/bin/python

import os
from time import time
import subprocess

def wccount(filename):
    return subprocess.check_output(['wc', '-l', filename])

def count_ratio(ref_num, denovo_num):
    return float(ref_num) / float(denovo_num) 

count_all_reads = 0
count_good_reads = 0

files = []
current_dir = os.getcwd()
for (dirpath, dirname, filenames) in os.walk(current_dir):
    files.extend(filenames)
    break

for f in files:
  if f.endswith("db.chimeric.fa"):
      db_file_name  = f
      txt_file_name = ".".join(f.split(".")[0:3]) + ".txt.chimeric.fa"
      print "db_file_name  = %s" % db_file_name
      print "txt_file_name = %s" % txt_file_name
      
#      start = time()
#      elapsed = (time() - start)
#      print "count time with mapcount: %s" % elapsed

      ref_num    = wccount(db_file_name).split()[0]
      denovo_num = wccount(txt_file_name).split()[0]
      print "db_lines = %s; txt_lines = %s" % (ref_num, denovo_num)
      ratio = count_ratio(ref_num, denovo_num)
      print "ratio = %s" % ratio 

#       
#     file = open(f)
#     print f
#     while 1:
#         line = file.readline()
#         if not line:
#             break
#         if line.startswith("number of pairs"):
#           counts_all = line.split(":")[1].split()[0]
#           # print counts_all
#           count_all_reads += int(counts_all)
#         if line.startswith("total pairs passed"):
#           count_good = line.split(":")[1].split()[0]
#           # print count_good
#           count_good_reads += int(count_good)
# 
#           print line.split(":")[1].split()[1].translate(None, '(')
# 
# print "="*50
# print current_dir
# print "count_all_reads = %s" % (count_all_reads)
# print "count_good_reads = %s" % (count_good_reads)
# print "percent kept for the run = %s%%" % (count_good_reads * 100 / count_all_reads)
