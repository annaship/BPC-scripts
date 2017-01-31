#! /bioware/python-2.7.5/bin/python

import os, sys

class Merge_stats:

    def __init__(self):

        self.verbose = False
        # TODO: to a method
        for arg in sys.argv:
          if arg == "-v":
            self.verbose = True
        self.count_all_reads = 0
        self.count_good_reads = 0

        # TODO: to a method
        self.files = []
        self.current_dir = os.getcwd()
        for (dirpath, dirname, filenames) in os.walk(self.current_dir):
            self.files.extend(filenames)
            break

        self.Number_of_pairs_analyzed = 0
        self.Prefix_failed_in_read_1 = 0
        self.Prefix_failed_in_read_2 = 0
        self.Prefix_failed_in_both = 0
        self.Passed_prefix_total = 0
        self.Failed_prefix_total = 0
        self.Merged_total = 0
        self.Complete_overlap_forced_total = 0
        self.Merge_failed_total = 0
        self.Merge_discarded_due_to_P = 0
        self.Merge_discarded_due_to_max_num_mismatches = 0
        self.Merge_discarded_due_to_Ns = 0
        self.Merge_discarded_due_to_Q30 = 0
        self.Pairs_discarded_due_to_min_expected_overlap = 0
        self.Num_mismatches_found_in_merged_reads = 0
        self.Mismatches_recovered_from_read_1 = 0
        self.Mismatches_recovered_from_read_2 = 0
        self.Mismatches_replaced_with_N = 0
        self.total_sequences_trimmed = 0
        self.number_of_sequences_to_trimm = 0

    # TODO: 
    def prepare_line(self):
        pass

    def read_1_STATS(self):
        self.num = 0
        self.line = self.line.strip()
        if (self.verbose):
          print(self.line)
        self.num = self.line.split()[-1]
        if (self.verbose):
          print(self.num)
        if self.line.startswith("Number of pairs analyzed"):
            self.Number_of_pairs_analyzed += int(self.num)
            if (self.verbose):
              print('Total: Number_of_pairs_analyzed + %s') % self.Number_of_pairs_analyzed
        elif self.line.startswith("Prefix failed in read 1"):
            self.Prefix_failed_in_read_1 += int(self.num)
        elif self.line.startswith("Prefix failed in read 2"):
            self.Prefix_failed_in_read_2 += int(self.num)
        elif self.line.startswith("Prefix failed in both"):
            self.Prefix_failed_in_both += int(self.num)
        elif self.line.startswith("Passed prefix total"):
            self.Passed_prefix_total += int(self.num)
        elif self.line.startswith("Failed prefix total"):
            self.Failed_prefix_total += int(self.num)
        elif self.line.startswith("Merged total"):
            self.Merged_total += int(self.num)
        elif self.line.startswith("Complete overlap forced total"):
            self.Complete_overlap_forced_total += int(self.num)
        elif self.line.startswith("Merge failed total"):
            self.Merge_failed_total += int(self.num)
        elif self.line.startswith("Merge discarded due to P"):
            self.Merge_discarded_due_to_P += int(self.num)
        elif self.line.startswith("Merge discarded due to max num mismatches"):
            self.Merge_discarded_due_to_max_num_mismatches += int(self.num)
        elif self.line.startswith("Merge discarded due to Ns"):
            self.Merge_discarded_due_to_Ns += int(self.num)
        elif self.line.startswith("Merge discarded due to Q30"):
            self.Merge_discarded_due_to_Q30 += int(self.num)
        elif self.line.startswith("Pairs discarded due to min expected overlap"):
            self.Pairs_discarded_due_to_min_expected_overlap += int(self.num)
        elif self.line.startswith("Num mismatches found in merged reads"):
            self.Num_mismatches_found_in_merged_reads += int(self.num)
        elif self.line.startswith("Mismatches recovered from read 1"):
            self.Mismatches_recovered_from_read_1 += int(self.num)
        elif self.line.startswith("Mismatches recovered from read 2"):
            self.Mismatches_recovered_from_read_2 += int(self.num)
        elif self.line.startswith("Mismatches replaced with N"):
            self.Mismatches_replaced_with_N += int(self.num)

    def read_1_MERGED_STATS(self):
        self.num = self.line.split(":")[1].split()[0]
        if (self.verbose):
          print(self.num)
        if self.line.startswith("number of sequences"):
            self.number_of_sequences_to_trimm += int(self.num)
        elif self.line.startswith("FP failed"):
            self.Prefix_failed_in_read_1 += int(self.num)
        elif self.line.startswith("RP failed"):
            self.Prefix_failed_in_read_2 += int(self.num)
        elif self.line.startswith("total pairs failed"):
            self.Failed_prefix_total += int(self.num)
        elif self.line.startswith("total sequences trimmed"):
            self.total_sequences_trimmed += int(self.num)

    def print_results(self):
        print "="*50
        print self.current_dir

        print('Number_of_pairs_analyzed (in all files)              = %s') % self.Number_of_pairs_analyzed
        print('Prefix_failed_in_read_1 (in all files)               = %s (%s%% from Number_of_pairs_analyzed)') % (self.Prefix_failed_in_read_1, self.get_percents(self.Prefix_failed_in_read_1))
        print('Prefix_failed_in_read_2 (in all files)               = %s (%s%% from Number_of_pairs_analyzed)') % (self.Prefix_failed_in_read_2, self.get_percents(self.Prefix_failed_in_read_2))
        print('Prefix_failed_in_both (in all files)                 = %s (%s%% from Number_of_pairs_analyzed)') % (self.Prefix_failed_in_both, self.get_percents(self.Prefix_failed_in_both))
        # print('Passed_prefix_total (in all files)                   = %s (%s%% from Number_of_pairs_analyzed)') % (self.Passed_prefix_total, self.get_percents(self.Passed_prefix_total))
        print('Failed_prefix_total (in all files)                   = %s (%s%% from Number_of_pairs_analyzed)') % (self.Failed_prefix_total, self.get_percents(self.Failed_prefix_total))
        print('Merged_total (in all files)                          = %s (%s%% from Number_of_pairs_analyzed)') % (self.Merged_total, self.get_percents(self.Merged_total))
        print('Complete_overlap_forced_total (in all files)         = %s (%s%% from Number_of_pairs_analyzed)') % (self.Complete_overlap_forced_total, self.get_percents(self.Complete_overlap_forced_total))
        print('Merge_failed_total (in all files)                    = %s (%s%% from Number_of_pairs_analyzed)') % (self.Merge_failed_total, self.get_percents(self.Merge_failed_total))
        print('From iu-merge-pairs readme: P value is the ratio of the number of mismatches and the length of the overlap.\n\tMerged sequences can be discarded based on this ratio. The default is 0.3.')
        print('Merge_discarded_due_to_P (in all files)              = %s (%s%% from Number_of_pairs_analyzed)') % (self.Merge_discarded_due_to_P, self.get_percents(self.Merge_discarded_due_to_P))
        print('Merge_discarded_due_to_max_num_mismatches (in all files) = %s (%s%% from Number_of_pairs_analyzed)') % (self.Merge_discarded_due_to_max_num_mismatches, self.get_percents(self.Merge_discarded_due_to_max_num_mismatches))
        print('Merge_discarded_due_to_Ns (in all files)             = %s (%s%% from Number_of_pairs_analyzed)') % (self.Merge_discarded_due_to_Ns, self.get_percents(self.Merge_discarded_due_to_Ns))
        print('Merge_discarded_due_to_Q30 (in all files)            = %s (%s%% from Number_of_pairs_analyzed)') % (self.Merge_discarded_due_to_Q30, self.get_percents(self.Merge_discarded_due_to_Q30))
        print('Pairs_discarded_due_to_min_expected_overlap (in all files) = %s') % (self.Pairs_discarded_due_to_min_expected_overlap)
        print('Num_mismatches_found_in_merged_reads (in all files)  = %s') % (self.Num_mismatches_found_in_merged_reads)
        print('Mismatches_recovered_from_read_1 (in all files)      = %s') % (self.Mismatches_recovered_from_read_1)
        print('Mismatches_recovered_from_read_2 (in all files)      = %s') % (self.Mismatches_recovered_from_read_2)
        print('Mismatches_replaced_with_N (in all files)            = %s') % (self.Mismatches_replaced_with_N)
        print('----------\nNumber_of_sequences_to_trimm             = %s') % (self.number_of_sequences_to_trimm)
        print('total_sequences_trimmed                  = %s (%s%% from Number_of_sequences_to_trimm), (%s%% from Number_of_pairs_analyzed)') % (self.total_sequences_trimmed, self.get_percents(self.total_sequences_trimmed, self.number_of_sequences_to_trimm), self.get_percents(self.total_sequences_trimmed))

    def get_percents(self, cnt_perc, hundred_perc = None):
        if hundred_perc is None:
            hundred_perc = self.Number_of_pairs_analyzed
        return "{0:.2f}".format(cnt_perc * 100 / float(hundred_perc))

if __name__ == "__main__":

    stats = Merge_stats()
    for f in stats.files:
      if f.endswith("_STATS"):
        file = open(f)
        if (stats.verbose):
          print f
        while 1:
            stats.line = file.readline()
            if not stats.line:
              break
            try:
                stats.num = 0
                stats.line = stats.line.strip()
                if (stats.verbose):
                  print(stats.line)

                if f.endswith("1_STATS"):
                    stats.read_1_STATS()
                if f.endswith("1_MERGED_STATS"):
                    stats.read_1_MERGED_STATS()
            except LookupError:
              pass
    stats.print_results()
