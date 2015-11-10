#! /bioware/python-2.7.5/bin/python

import os, sys

verbose = False
for arg in sys.argv:
  if arg == "-v":
    verbose = True

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
    if (verbose):
      print f
    while 1:
        line = file.readline()

        if not line:
          break
        try:
          num = 0
          line = line.strip()
          if (verbose):
            print(line)
          num = line.split(":")[-1].split(" ")[1]
          if (verbose):
            print(num)
          
          if line.startswith("number of pairs"):
              number_of_pairs += int(num)
              if (verbose):
                print('Total: number_of_pairs + %s') % number_of_pairs

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

def get_percents(cnt_perc):
  return "{0:.2f}".format(cnt_perc * 100 / float(number_of_pairs))


print "="*50
print current_dir

print('number_of_pairs in all files = %s') % number_of_pairs
print('total_pairs_passed in all files = %s         (%s%% from Number_of_pairs_analyzed)') % (total_pairs_passed, get_percents(total_pairs_passed))
print('perfect_pairs_with_Ns in all files = %s      (%s%% from Number_of_pairs_analyzed)') % (perfect_pairs_with_Ns, get_percents(perfect_pairs_with_Ns))
print('recovered_ambiguous_bases1 in all files = %s (%s%% from Number_of_pairs_analyzed)') % (recovered_ambiguous_bases1, get_percents(recovered_ambiguous_bases1))
print('recovered_ambiguous_bases2 in all files = %s (%s%% from Number_of_pairs_analyzed)') % (recovered_ambiguous_bases2, get_percents(recovered_ambiguous_bases2))
print('total_pairs_failed in all files = %s         (%s%% from Number_of_pairs_analyzed)') % (total_pairs_failed, get_percents(total_pairs_failed))
print('FP_failed_in_both_pairs in all files = %s    (%s%% from Number_of_pairs_analyzed)') % (FP_failed_in_both_pairs, get_percents(FP_failed_in_both_pairs))
print('FP_failed_only_in_pair_1 in all files = %s   (%s%% from Number_of_pairs_analyzed)') % (FP_failed_only_in_pair_1, get_percents(FP_failed_only_in_pair_1))
print('FP_failed_only_in_pair_2 in all files = %s   (%s%% from Number_of_pairs_analyzed)') % (FP_failed_only_in_pair_2, get_percents(FP_failed_only_in_pair_2))
print('RP_failed_in_both_pairs in all files = %s    (%s%% from Number_of_pairs_analyzed)') % (RP_failed_in_both_pairs, get_percents(RP_failed_in_both_pairs))
print('RP_failed_only_in_pair_1 in all files = %s   (%s%% from Number_of_pairs_analyzed)') % (RP_failed_only_in_pair_1, get_percents(RP_failed_only_in_pair_1))
print('RP_failed_only_in_pair_2 in all files = %s   (%s%% from Number_of_pairs_analyzed)') % (RP_failed_only_in_pair_2, get_percents(RP_failed_only_in_pair_2))
print('FAILED_FP in all files = %s                  (%s%% from Number_of_pairs_analyzed)') % (FAILED_FP, get_percents(FAILED_FP))
print('FAILED_RP in all files = %s                  (%s%% from Number_of_pairs_analyzed)') % (FAILED_RP, get_percents(FAILED_RP))


