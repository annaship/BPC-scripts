import os
import sys
import re 
import getpass
sys.path.append("/Users/ashipunova/BPC/merens-illumina-utils/IlluminaUtils/lib/")
sys.path.append("/Users/ashipunova/bin/illumina-utils/illumina-utils/IlluminaUtils/utils/")
sys.path.append("/xraid/bioware/linux/seqinfo/bin")

from time import sleep, time, gmtime, strftime
import fastqlib as fq

class CreateIniFiles:
    """
    create ini files     
    """
    def __init__(self, args):
        self.get_args(args)
        # self.out_files = {} 
        self.out_file_names_barcodes = set()
        self.sample_barcodes = {}
        # self.log_file_name = self.in_fastq_file_name + ".log"
        # file_list             = self.get_all_files_by_ext(self.out_file_path, "ini")        
        # self.in_file_list = set()
        
    """util"""    
    def get_args(self, args):
        self.in_barcode_file_name = args.in_barcode_file_name
        self.pair_1_prefix = args.pair_1_prefix
        self.pair_2_prefix = args.pair_2_prefix
        # self.compressed = args.compressed
        # self.in_fastq_file_name = args.in_fastq_file_name
        self.input_dir = args.input_dir
        self.out_file_path = args.out_file_path
        # self.its = args.its
        
        if (args.out_file_path == ""):
            self.out_file_path = "res_" + self.input_dir
        
    # can be used instead of get_file_name_by_barcode_from_prep
    def get_all_files_by_ext(self, walk_dir_name, extension):
        return [file for file in os.listdir(walk_dir_name) if file.endswith(extension)]    
        
    def make_users_email(self):
        username = getpass.getuser() 
        return username + "@mbl.edu"
        
    # todo: DRY! The same in demultiplex_class.py
    def get_file_name_by_barcode_from_prep(self):
        # in_barcode_file_name = "prep_template_MoBE_dairy_BITS.txt"
        with open(self.in_barcode_file_name) as openfileobject:
            # rm headline from tsv
            next(openfileobject)            
            for line in openfileobject:
                barcode_line = line.split("\t")
                self.sample_barcodes[barcode_line[1]] = barcode_line[0]
                # print "barcode_line[0] = %s; barcode_line[1] = %s" % (barcode_line[0], barcode_line[1])

        
    """make_ini"""
    def create_inis(self):
        email = self.make_users_email()
        self.out_file_names_barcodes = set(self.sample_barcodes.keys())
        print "self.out_file_names_barcodes = %s" % self.out_file_names_barcodes
        
        for idx_key in self.out_file_names_barcodes:
            dataset_name = self.sample_barcodes[idx_key]
            # print "out_file_names_barcodes key = %s" % (idx_key)
            text = """[general]
dataset_name = %s
researcher_email = %s
input_directory = %s
output_directory = %s

[files]
pair_1 = %s
pair_2 = %s
""" % (dataset_name, email, self.input_dir, "../" + self.out_file_path, idx_key + "_R1.fastq", idx_key + "_R2.fastq")

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

#     """ make cluster jobs """
#     def create_job_array_script(self, command_line):
#         files_string      = " ".join(self.out_file_names_barcodes)
#         files_list_size   = len(self.out_files)
#         args = " --enforce-Q30-check "
#         if (self.its == "yes"):
#             args += " --marker-gene-stringent "
# 
#         # command_file_name = os.path.basename(command_line.split(" ")[0])
#         command_line = command_line + args
#         script_file_name  = self.in_fastq_file_name + ".sge_script.sh"
#         print "command_line = %s" % command_line
#         print "script_file_name = %s" % script_file_name
#         script_file_name_full = os.path.join(self.out_file_path, script_file_name)
#         log_file_name     = script_file_name + ".sge_script.sh.log"
#         email_mbl         = self.make_users_email()
#         text = (
#                 '''#!/bin/bash
# #$ -cwd
# #$ -S /bin/bash
# #$ -N %s
# # Giving the name of the output log file
# #$ -o %s
# # Combining output/error messages into one file
# #$ -j y
# # Send mail to these users
# #$ -M %s
# # Send mail at job end; -m eas sends on end, abort, suspend.
# #$ -m eas
# #$ -t 1-%s
# # Now the script will iterate %s times.
# 
# file_list=(%s)
# 
# 
# echo "\$SGE_TASK_ID = $SGE_TASK_ID"
# 
# i=$(expr $SGE_TASK_ID - 1)
#  echo "i = $i"
# # . /etc/profile.d/modules.sh
# # . /xraid/bioware/bioware-loader.sh
# . /xraid/bioware/Modules/etc/profile.modules
# module load bioware
# 
# ini_file=${file_list[$i]}.ini
# echo "%s $ini_file"  
# %s $ini_file  
# ''' % (script_file_name, log_file_name, email_mbl, files_list_size, files_list_size, files_string, command_line, command_line)
#                 )
#         self.open_write_close(script_file_name_full, text)
#         return script_file_name
