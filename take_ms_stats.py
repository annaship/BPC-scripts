#! /bioware/python-2.7.5/bin/python

import os
count_all_reads = 0
count_good_reads = 0

files = []
current_dir = os.getcwd()
for (dirpath, dirname, filenames) in os.walk(current_dir):
    files.extend(filenames)
    break

print "Number of pairs analyzed; Merged total"
    
for f in files:
  if f.endswith("_STATS"):
    file = open(f)
    print f
    while 1:
        line = file.readline()
        if not line:
            break
        if line.startswith("Number of pairs analyzed"):
          counts_all = line.split()[4]
          print counts_all
          count_all_reads += int(counts_all)
        if line.startswith("Merged total"):
          count_good = line.split()[2]
          print count_good
          count_good_reads += int(count_good)
                
print "="*50    
print current_dir
print "count_all_reads = %s" % (count_all_reads)
print "count_good_reads = %s" % (count_good_reads)
print "percent kept for the run = %s%%" % (count_good_reads * 100 / count_all_reads)
