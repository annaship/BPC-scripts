#! /bioware/python-2.7.5/bin/python

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    OKRED = '\033[31m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

import os
count_all_reads  = 0
count_good_reads = 0
counts_all       = 0
count_good       = 0
color            = ""
rsum             = 0

files = []
current_dir = os.getcwd()
for (dirpath, dirname, filenames) in os.walk(current_dir):
    files.extend(filenames)
    break

print 'From iu-merge-pairs readme: P value is the ratio of the number of mismatches and the length of the overlap.\nMerged sequences can be discarded based on this ratio. The default is 0.3.'
print "Number of pairs analyzed; Merged total"

def no_data_msg():
  color = bcolors.OKRED
  print "NO DATA"
  color = bcolors.ENDC
  
def sum_reads(count_reads, counts_all):  
  try:
    return int(count_reads) + int(counts_all)
  except ValueError:
    count_reads = 0
    no_data_msg()
  except:
    raise
  
for f in sorted(files):
  if f.endswith("_STATS"):
    file = open(f)
    print f
    while 1:
        line = file.readline()
        if not line:
            break
        if line.startswith("Number of pairs analyzed"):
          counts_all = line.split()[-1]
          print counts_all
          count_all_reads = sum_reads(count_all_reads, counts_all)
          # print "count_all_reads interim = "
          # print count_all_reads
        if line.startswith("Merged total"):
          count_good = line.split()[-1]
          print count_good
          count_good_reads = sum_reads(count_good_reads, count_good)
          # print "count_good_reads interim = "
          # print count_good_reads
          
    try:
      percent = int(count_good) * float(100) / int(counts_all)
    except ZeroDivisionError:
      percent = 0
      no_data_msg()
    except ValueError:
      percent = 0
      no_data_msg()
    except:
      raise
    if percent < 80 and percent > 60:
	color = bcolors.OKBLUE
    elif percent < 60:
	color = bcolors.FAIL
    elif percent > 80:
	color = bcolors.OKGREEN
    print("%s%%%.2f %s" % (color, percent, bcolors.ENDC))
                
print "="*50    
print current_dir
print "count_all_reads  = %s" % (count_all_reads)
print "count_good_reads = %s" % (count_good_reads)
try:
    print "percent kept for the run = %s%%" % (count_good_reads * 100 / count_all_reads)
except:
    pass

