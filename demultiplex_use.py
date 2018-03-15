import os, sys
from demultiplex_class import Demultiplex

# todo: make time work

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='''Demultiplex Illumina fastq. Will make fastq files per barcode from "in_barcode_file_name".
    Command line example: time python demultiplex_use.py --in_barcode_file_name "prep_template.txt" --in_fastq_file_name S1_L001_R1_001.fastq.gz --out_dir results --compressed
    
    ''')
    # todo: add user_config
    # parser.add_argument('--user_config', metavar = 'CONFIG_FILE',
    #                                     help = 'User configuration to run')
    parser.add_argument('--in_barcode_file_name', required = True,
                                        help = 'Comma delimited file with sample names in the first column and its barcodes in the second.')
    parser.add_argument('--in_fastq_file_name', required = True,
                                        help = 'Fastq file name for the read 1 (assuming read 2 differs only by R1/2).')                                        
    parser.add_argument('--out_dir', default = "",
                                        help = 'Output directory. Default is res_\{IN_FASTQ_FILE_NAME\}. Should be created upfront manually.')
    parser.add_argument('--compressed', '-c', action = "store_true", default = False,
                                        help = 'Use if fastq compressed. Default is %(default)s.')
                                        
    args = parser.parse_args()
    
    if not os.path.exists(args.in_fastq_file_name):
        print("Input fastq file '%s' does not exist." % args.in_fastq_file_name)
        sys.exit()
    
    #     if len(sys.argv)==1:
    #         parser.print_help()
    #         sys.exit(1)
        

    demultiplex = Demultiplex(args)

    # =========
    demultiplex.get_file_name_by_barcode_from_prep()
    print("demultiplex.get_file_name_by_barcode_from_prep()")

    demultiplex.open_sample_files()
    print("demultiplex.open_sample_files()")
    
    demultiplex.write_to_files_r1()
    print("demultiplex.write_to_files_r1()")
    
    demultiplex.write_to_files_r2()
    print("demultiplex.write_to_files_r2()")
    
    # illumina_files.create_inis()
    # print("illumina_files.create_inis()")
    # 
    # command_name = "merge-illumina-pairs"
    # 
    # illumina_files.create_job_array_script(command_name)
    # print("illumina_files.create_job_array_script(command_name, its) = %s,  time: %s" % (command_name, elapsed))

    
