import os
import sys
import re
import getpass
sys.path.append("/Users/ashipunova/BPC/merens-illumina-utils/IlluminaUtils/lib/")
sys.path.append("/Users/ashipunova/bin/illumina-utils/illumina-utils/IlluminaUtils/utils/")
sys.path.append("/xraid/bioware/linux/seqinfo/bin")

import IlluminaUtils.lib.fastqlib as fq

class Demultiplex:
    """
    0) from run create all dataset_lines names files in output dir
    1) split fastq files from casava into files with dataset_names

    """
    def __init__(self, args):
        self.get_args(args)
        self.out_files = {}
        self.id_sample_idx = {}
        self.out_file_names_barcodes = set()
        self.sample_barcodes = {}
        self.log_file_name = self.in_fastq_file_name + ".log"

    """util"""

    def get_args(self, args):
        print "AAA args = %s" % (args)
        self.in_barcode_file_name = args.in_barcode_file_name
        self.compressed = args.compressed

        self.in_fastq_file_name = args.in_fastq_file_name
        self.out_dir = args.out_dir

        if (args.out_dir == ""):
            self.out_dir = "res_" + self.in_fastq_file_name

    """demultiplex"""
    def get_file_name_by_barcode_from_prep(self):
        # in_barcode_file_name = "prep_template_MoBE_dairy_BITS.txt"
        with open(self.in_barcode_file_name) as openfileobject:
            # rm headline from tsv
            # next(openfileobject)
            for line in openfileobject:
                barcode_line = line.strip('\n').split(",")
                try:
                    # print "barcode_line = %s" % (barcode_line)
                    # print "barcode_line = %s, barcode_line[0] = %s; barcode_line[1] = %s" % (barcode_line, barcode_line[0], barcode_line[1])
                    self.sample_barcodes[barcode_line[1]] = barcode_line[0]
                except IndexError:
                    if barcode_line == ['']:
                        pass
                    else:
                        raise
                except:
                    raise

    def open_sample_files(self):
        # print "self.sample_barcodes.keys()"
        # print self.sample_barcodes.keys()
        self.out_file_names_barcodes = set(self.sample_barcodes.keys())
        # print "self.out_file_names_barcodes = %s" % self.out_file_names_barcodes
        file_name_base = [i + "_R1" for i in self.out_file_names_barcodes] + [i + "_R2" for i in self.out_file_names_barcodes]
        for f_name in file_name_base:
            out_file = os.path.join(self.out_dir, f_name + ".fastq")
            self.out_files[f_name] = fq.FastQOutput(out_file)
        self.out_files["unknown"] = fq.FastQOutput(os.path.join(self.out_dir, "unknown" + ".fastq"))

    def close_sample_files(self):
        [o_file[1].close() for o_file in self.out_files.iteritems()]
        return

    def make_id_dataset_idx(self, e_header_line, barcode):
        short_id1 = e_header_line.split()[0]
        short_id2 = ":".join(e_header_line.split()[1].split(":")[1:])
        id2 = short_id1 + " 2:" + short_id2
        self.id_sample_idx[id2] = barcode

    def get_run_key(self, e_sequence):
        if self.has_ns():
            return ("NNNN" + e_sequence[4:9])
        else:
            return e_sequence[0:5]

    def has_ns(self):
        return any("NNNN" in s for s in self.sample_barcodes)

    def open_current_file(self, filename):
        return fq.FastQSource(filename, self.compressed)

    def write_to_files_r1(self):
      fastq_input = self.open_current_file(self.in_fastq_file_name)

      while fastq_input.next():
          e = fastq_input.entry
          if int(e.pair_no) == 1:
              barcode = self.get_run_key(e.sequence)
              self.make_id_dataset_idx(e.header_line, barcode)
              try:
                  self.out_files[barcode + "_R1"].store_entry(e)
              except:
                  self.out_files["unknown"].store_entry(e)

    def write_to_files_r2(self):
      file_r2_name = re.sub(r'_R1_', '_R2_', self.in_fastq_file_name)

      f2_input = self.open_current_file(file_r2_name)

      while f2_input.next():
          e = f2_input.entry
          if (int(e.pair_no) == 2) and (e.header_line in self.id_sample_idx):
              file_name = self.id_sample_idx[e.header_line] + "_R2"
              # print "file_name = %s" % file_name
              try:
                  self.out_files[file_name].store_entry(e)
              except:
                  self.out_files["unknown"].store_entry(e)
          try:
              self.out_files[barcode + "_R2"].store_entry(e)
          except:
              self.out_files["unknown"].store_entry(e)

