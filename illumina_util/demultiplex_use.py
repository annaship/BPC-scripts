import os, sys
from demultiplex_class import Demultiplex

# todo: make time work

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='''Demultiplex Illumina fastq. Will make fastq files per barcode from "in_barcode_file_name"
    Command line example: time python demultiplex_use.py --in_barcode_file_name "prep_template.txt" --in_fastq_file_name S1_L001_R1_001.fastq.gz --out_file_path results
    
    ''')
    # todo: add user_config
    # parser.add_argument('--user_config', metavar = 'CONFIG_FILE',
    #                                     help = 'User configuration to run')
    parser.add_argument('--out_file_path', default = "",
                                        help = 'Output directory. Default is res_\{in_fastq_file_name\}. Should be created upfront manually.')
    
    parser.add_argument('--in_barcode_file_name',
                                        help = 'Tab delimited file with sample names in the first column and its barcode in the second.')
    parser.add_argument('--in_fastq_file_name',
                                        help = 'Fastq file name for the read 1 (assuming read 2 differs only by R1/2).')
    parser.add_argument('--compressed', default = "yes",
                                        help = 'Is fastq compressed? (yes/no) Default is %(default)d.')


    args = parser.parse_args()
    
    if not os.path.exists(args.in_fastq_file_name):
        print "Input fastq file does not exist (at least not at '%s')." % args.in_fastq_file_name
        print
        sys.exit()

    demultiplex = Demultiplex(args)


    # =========
    demultiplex.get_file_name_by_barcode_from_prep()
    print "demultiplex.get_file_name_by_barcode_from_prep()"

    demultiplex.open_sample_files()
    print "demultiplex.open_sample_files()"
    
    demultiplex.write_to_files_r1()
    print "demultiplex.write_to_files_r1()"
    
    demultiplex.write_to_files_r2()
    print "demultiplex.write_to_files_r2()"
    
    # illumina_files.create_inis()
    # print "illumina_files.create_inis()"
    # 
    # command_name = "merge-illumina-pairs"
    # 
    # illumina_files.create_job_array_script(command_name)
    # print "illumina_files.create_job_array_script(command_name, its) = %s,  time: %s" % (command_name, elapsed)

    
