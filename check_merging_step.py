#! python

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
unique_fasta_files = []
suff_list = ['.nonchimeric.fa', '.fa.unique', 'MERGED_V6_PRIMERS_REMOVED.unique']

files = []
current_dir = os.getcwd()
for (dirpath, dirname, filenames) in os.walk(current_dir):
    files.extend(filenames)
    break

for f in sorted(files):
  for suff in suff_list:    
    if f.endswith(suff):
      unique_fasta_files.append(f)

print("="*50)    
print(current_dir)
count_unique_fasta_files = len(unique_fasta_files)
meging_step_worked = count_unique_fasta_files > 0
if meging_step_worked:
  color = bcolors.OKGREEN
  msg = "The merging step has finished sucessfully with %s uniqued file(s), is it correct?" % (count_unique_fasta_files)
  print("%s%s %s" % (color, msg, bcolors.ENDC))
else:
  color = bcolors.FAIL
  msg = "The merging step hasn't finished sucessfully, there are no files with endings like %s" % (", ".join(suff_list))
  print("%s%s %s" % (color, msg, bcolors.ENDC))




