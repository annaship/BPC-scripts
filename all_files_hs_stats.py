#! /bioware/python-2.7.5/bin/python

import os
count_all_reads = 0
count_good_reads = 0

files = []
current_dir = os.getcwd()
for (dirpath, dirname, filenames) in os.walk(current_dir):
    files.extend(filenames)
    break

# total pairs passed              : 16 (%0.01 of all pairs)
#   perfect pairs with Ns         : 0 (%0.00 of perfect pairs)
#   recovered ambiguous bases (p1): 0 (%0.00 of perfect pairs)
#   recovered ambiguous bases (p2): 0 (%0.00 of perfect pairs)
# total pairs failed              : 115924 (%99.99 of all pairs)
#   FP failed in both pairs       : 895 (%0.77 of all failed pairs)
#   FP failed only in pair 1      : 0 (%0.00 of all failed pairs)
#   FP failed only in pair 2      : 111240 (%95.96 of all failed pairs)
#   RP failed in both pairs       : 710 (%0.61 of all failed pairs)
#   RP failed only in pair 1      : 549 (%0.47 of all failed pairs)
#   RP failed only in pair 2      : 2530 (%2.18 of all failed pairs)
#   FAILED_FP                     : 112135 (%96.73 of all failed pairs)
#   FAILED_RP                     : 3789 (%3.27 of all failed pairs)


number_of_pairs = 0
total_pairs_passed = 0
perfect_pairs_with_Ns = 0
recovered_ambiguous_bases1 = 0
recovered_ambiguous_bases2 = 0
total_pairs_failed = 0
FP_failed_in_both_pairs = 0
FP_failed_only_in_pair_1 = 0
FP_failed_only_in_pair_2 = 0
RP_failed_in_both_pairs = 0
RP_failed_only_in_pair_1 = 0
RP_failed_only_in_pair_2 = 0
FAILED_FP = 0
FAILED_RP = 0

for f in files:
  if f.endswith("STATS.txt"):
    file = open(f)
    print f
    while 1:
        line = file.readline()

        if not line:
          break
        try:
          num = 0
          line = line.strip()
          print(line)
          num = line.split(":")[-1].split(" ")[1]
          print(num)
          
          if line.startswith("number of pairs"):
              number_of_pairs += int(num)
              print('URA: number_of_pairs + %s') % number_of_pairs

          elif line.startswith("total pairs passed"):
              total_pairs_passed += int(num)
          elif line.startswith("perfect pairs with Ns"):
              perfect_pairs_with_Ns += int(num)
          elif line.startswith("recovered ambiguous bases (p1)"):
              recovered_ambiguous_bases1 += int(num)
          elif line.startswith("recovered ambiguous bases (p2)"):
              recovered_ambiguous_bases2 += int(num)
          elif line.startswith("total pairs failed"):
              total_pairs_failed += int(num)
          elif line.startswith("FP failed in both pairs"):
              FP_failed_in_both_pairs += int(num)
          elif line.startswith("FP failed only in pair 1"):
              FP_failed_only_in_pair_1 += int(num)
          elif line.startswith("FP failed only in pair 2"):
              FP_failed_only_in_pair_2 += int(num)
          elif line.startswith("RP failed in both pairs"):
              RP_failed_in_both_pairs += int(num)
          elif line.startswith("RP failed only in pair 1"):
              RP_failed_only_in_pair_1 += int(num)
          elif line.startswith("RP failed only in pair 2"):
              RP_failed_only_in_pair_2 += int(num)
          elif line.startswith("FAILED_FP"):
              FAILED_FP += int(num)
          elif line.startswith("FAILED_RP"):
              FAILED_RP += int(num)

        except LookupError:
          pass

print "="*50
print current_dir

print('number_of_pairs in all files = %s') % number_of_pairs
print('total_pairs_passed in all files = %s') % total_pairs_passed
print('perfect_pairs_with_Ns in all files = %s') % perfect_pairs_with_Ns
print('recovered_ambiguous_bases1 in all files = %s') % recovered_ambiguous_bases1
print('recovered_ambiguous_bases2 in all files = %s') % recovered_ambiguous_bases2
print('total_pairs_failed in all files = %s') % total_pairs_failed
print('FP_failed_in_both_pairs in all files = %s') % FP_failed_in_both_pairs
print('FP_failed_only_in_pair_1 in all files = %s') % FP_failed_only_in_pair_1
print('FP_failed_only_in_pair_2 in all files = %s') % FP_failed_only_in_pair_2
print('RP_failed_in_both_pairs in all files = %s') % RP_failed_in_both_pairs
print('RP_failed_only_in_pair_1 in all files = %s') % RP_failed_only_in_pair_1
print('RP_failed_only_in_pair_2 in all files = %s') % RP_failed_only_in_pair_2
print('FAILED_FP in all files = %s') % FAILED_FP
print('FAILED_RP in all files = %s') % FAILED_RP


