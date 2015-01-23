import os
import sys
import re 
import getpass
sys.path.append("/Users/ashipunova/BPC/merens-illumina-utils/IlluminaUtils/lib/")
sys.path.append("/Users/ashipunova/bin/illumina-utils/illumina-utils/IlluminaUtils/utils/")
sys.path.append("/xraid/bioware/linux/seqinfo/bin")

from time import sleep, time, gmtime, strftime
import fastqlib as fq

class IlluminaFiles:
    """
    0) from run create all dataset_lines names files in output dir
    1) split fastq files from casava into files with dataset_names
    2) create ini files 
    3) process them through Meren's script
    4) result - files dataset_lane-PERFECT_reads.fa.unique with frequencies - to process with env454upload()    
    
    """
    def __init__(self, args):
        self.get_args(args)
        self.out_files = {} 
        self.id_sample_idx = {}
        self.out_file_names_barcodes = set()
        self.sample_barcodes = {}
        self.log_file_name = self.in_fastq_file_name + ".log"
        # file_list             = self.get_all_files_by_ext(self.out_file_path, "ini")        
        self.in_file_list = set()
        
    """util"""
    
    def get_args(self, args):
        self.in_barcode_file_name = args.in_barcode_file_name
        self.pair_1_prefix = args.pair_1_prefix
        self.pair_2_prefix = args.pair_2_prefix
        self.compressed = args.compressed
        self.in_fastq_file_name = args.in_fastq_file_name
        self.input_dir = args.input_dir
        self.out_file_path = args.out_file_path
        self.its = args.its
        
        if (args.out_file_path == ""):
            self.out_file_path = "res_" + self.in_fastq_file_name
        
    
    def get_all_files_by_ext(self, walk_dir_name, extension):
        return [file for file in os.listdir(walk_dir_name) if file.endswith(extension)]    
    def make_users_email(self):
        username = getpass.getuser() 
        return username + "@mbl.edu"
    def print_both(self, message):
        print message
        open_write_close(self, log_file_name, message)        
        
    """demultiplex"""
    def get_file_name_by_barcode_from_prep(self):
        # in_barcode_file_name = "prep_template_MoBE_dairy_BITS.txt"
        with open(self.in_barcode_file_name) as openfileobject:
            # rm headline from tsv
            next(openfileobject)            
            for line in openfileobject:
                barcode_line = line.split("\t")
                self.sample_barcodes[barcode_line[1]] = barcode_line[0]
                # print "barcode_line[0] = %s; barcode_line[1] = %s" % (barcode_line[0], barcode_line[1])

    def open_sample_files(self):
        # print self.sample_barcodes.keys()
        self.out_file_names_barcodes = set(self.sample_barcodes.keys())
        print "self.out_file_names_barcodes = %s" % self.out_file_names_barcodes
        file_name_base = [i + "_R1" for i in self.out_file_names_barcodes] + [i + "_R2" for i in self.out_file_names_barcodes]
        for f_name in file_name_base:
            out_file = os.path.join(self.out_file_path, f_name + ".fastq")
            self.out_files[f_name] = fq.FastQOutput(out_file)
        self.out_files["unknown"] = fq.FastQOutput(os.path.join(self.out_file_path, "unknown" + ".fastq"))        

    def close_sample_files(self):
        [o_file[1].close() for o_file in self.out_files.iteritems()] 
        return
    
    def make_id_dataset_idx(self, e_header_line, barcode):
        short_id1 = e_header_line.split()[0]
        short_id2 = ":".join(e_header_line.split()[1].split(":")[1:])
        id2 = short_id1 + " 2:" + short_id2
        self.id_sample_idx[id2] = barcode

    def write_to_files_r1(self):
      fastq_input = fq.FastQSource(self.in_fastq_file_name, self.compressed)
  
      while fastq_input.next():
          e = fastq_input.entry
          if int(e.pair_no) == 1:
              barcode = e.sequence[:8]
              self.make_id_dataset_idx(e.header_line, barcode)
              try:
                  self.out_files[barcode + "_R1"].store_entry(e)      
              except:
                  self.out_files["unknown"].store_entry(e)
      
    def write_to_files_r2(self):
      file_r2_name = re.sub(r'_R1_', '_R2_', self.in_fastq_file_name)
      # print "file_r2_name = %s" % file_r2_name
      f2_input  = fq.FastQSource(file_r2_name, self.compressed)
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

    """make_ini"""

    def create_inis(self):
        email = self.make_users_email()
        
        for idx_key in self.out_file_names_barcodes:
            # print "out_file_names_barcodes key = %s" % (idx_key)
    #        for dataset in self.dataset_emails.keys():
    #            dataset_idx_base = dataset + "_" + self.dataset_index[dataset]
    #            print "dataset = %s, self.dataset_emails[dataset] = %s" % (dataset, self.dataset_emails[dataset])
            text = """[general]
project_name = %s
researcher_email = %s
input_directory = %s
output_directory = %s

[files]
pair_1 = %s
pair_2 = %s
""" % (idx_key, email, self.input_dir, "../" + self.out_file_path, idx_key + "_R1.fastq", idx_key + "_R2.fastq")

            # primers = self.get_primers()  
            text += """
[prefixes]
pair_1_prefix = ^""" + self.pair_1_prefix + "\npair_2_prefix = ^" + self.pair_2_prefix
            
            ini_file_name = os.path.join(self.out_file_path,  idx_key + ".ini")
            self.open_write_close(ini_file_name, text)

    def open_write_close(self, script_file_name, text):
        ini_file = open(script_file_name, "w")
        ini_file.write(text)
        ini_file.close()

    """ make cluster jobs """
    def create_job_array_script(self, command_line):
        files_string      = " ".join(self.out_file_names_barcodes)
        files_list_size   = len(self.out_files)
        args = " --enforce-Q30-check "
        if (self.its == "yes"):
            args += " --marker-gene-stringent "

        # command_file_name = os.path.basename(command_line.split(" ")[0])
        command_line = command_line + args
        script_file_name  = self.in_fastq_file_name + ".sge_script.sh"
        print "command_line = %s" % command_line
        print "script_file_name = %s" % script_file_name
        script_file_name_full = os.path.join(self.out_file_path, script_file_name)
        log_file_name     = script_file_name + ".sge_script.sh.log"
        email_mbl         = self.make_users_email()
        text = (
                '''#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N %s
# Giving the name of the output log file
#$ -o %s
# Combining output/error messages into one file
#$ -j y
# Send mail to these users
#$ -M %s
# Send mail at job end; -m eas sends on end, abort, suspend.
#$ -m eas
#$ -t 1-%s
# Now the script will iterate %s times.

file_list=(%s)


echo "\$SGE_TASK_ID = $SGE_TASK_ID"

i=$(expr $SGE_TASK_ID - 1)
 echo "i = $i"
# . /etc/profile.d/modules.sh
# . /xraid/bioware/bioware-loader.sh
. /xraid/bioware/Modules/etc/profile.modules
module load bioware

ini_file=${file_list[$i]}.ini
echo "%s $ini_file"  
%s $ini_file  
''' % (script_file_name, log_file_name, email_mbl, files_list_size, files_list_size, files_string, command_line, command_line)
                )
        self.open_write_close(script_file_name_full, text)
        return script_file_name
