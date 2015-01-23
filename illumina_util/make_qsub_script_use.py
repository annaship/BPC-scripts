import os
from make_qsub_script_class import PrepareMerge, Util
from time import sleep, time, gmtime, strftime

# todo: make time work

elapsed = ""
if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Demultiplex Illumina fastq. Will make fastq files per barcode from "in_barcode_file_name" and a shell script "*.sh" to run on cluster for merging')
    # todo: add user_config
    # parser.add_argument('--user_config', metavar = 'CONFIG_FILE',
    #                                     help = 'User configuration to run')
    parser.add_argument('-o', '--output_file_prefix', metavar = 'OUTPUT_FILE_PREFIX', default = None,
                                        help = 'Output file prefix (which will be used as a prefix\
                                                for files that appear in output directory)')
    # parser.add_argument('--min-overlap-size', type = int, default = 15, metavar = 'INT',
    #                                     help = 'Minimum expected overlap. Default is %(default)d.')
    # ITS
    # --pair_1_prefix "........CTACCTGCGGA[AG]GGATCA"
    # --pair_2_prefix "GAGATCC[AG]TTG[CT]T[AG]AAAGTT"
    # v4            
    # --pair_1_prefix ^........GTGCCAGC[AC]GCCGCGGTAA
    # --pair_2_prefix ^GGACTAC[ACT][ACG]GGGT[AT]TCTAAT

    parser.add_argument('--pair_1_prefix',
                                        help = 'Forward (read1) primer. Use regular expressions like "........CTACCTGCGGA[AG]GGATCA".')
    parser.add_argument('--pair_2_prefix',
                                        help = 'Reverse (read2) primer. Use regular expressions like "GAGATCC[AG]TTG[CT]T[AG]AAAGTT".')
    parser.add_argument('--its', default = "no",
                                        help = 'Is it an ITS data? (yes/no) Default is %(default)d.')

    
    parser.add_argument('--out_file_path', default = "",
                                        help = 'Output directory. Default is res_\{in_fastq_file_name\}.')
    
    parser.add_argument('--input_dir', default = ".",
                                        help = 'Input directory. Default is %(default)d.')
    
    # parser.add_argument('--in_barcode_file_name',
    #                                     help = 'Tab delimited file with sample names in the first column and its barcode in the second.')
    # parser.add_argument('--in_fastq_file_name',
    #                                     help = 'Fastq file name for the read 1 (assuming read 2 differs only by R1/2).')
    parser.add_argument('--in_fastq_name_ending', default = "_R1.fastq.gz",
                                        help = 'Fastq files path and template for the read 1 (assuming read 2 differs only by 2 vs. 1). Default is %(default)d.')                                        
                                        
    parser.add_argument('--compressed', default = "yes",
                                        help = 'Is fastq compressed? (yes/no) Default is %(default)d.')
    parser.add_argument('--ini_only', default = "no",
                                                                            help = 'Make ini file and exit. Use for already demultiplex files. Default is %(default)d.')


    args = parser.parse_args()
    
    # if not os.path.exists(args.in_fastq_file_name):
    #     print "Input fastq file does not exist (at least not at '%s')." % args.in_fastq_file_name
    #     print
    #     sys.exit()

    prepare_merge = PrepareMerge(args)



    # if not os.path.exists(args.user_config):
    #     print "Config file does not exist (at least not at '%s')." % args.user_config
    #     print
    #     sys.exit()
    # 
    # 
    # user_config = ConfigParser.ConfigParser()
    # user_config.read(args.user_config)

    # try: 
    #     config = RunConfiguration(user_config)
    # except ConfigError, e:
    #     print "There is something wrong with the config file. This is what we know: \n\n", e
    #     print
    #     sys.exit()

    # merger = Merger(config)
    # merger.output_file_prefix = args.output_file_prefix
    # merger.p_value = args.p_value
    # sys.exit(merger.run())
                                        
    
    
    # =========
    # get_file_name_by_barcode_from_prep

    # start = time.time()
    prepare_merge.create_inis()
    # elapsed = (time.time() - start)
    print "prepare_merge.create_inis() time: %s" % elapsed
    
    command_name = "merge-illumina-pairs"

    # start = time.time()
    prepare_merge.create_job_array_script(command_name)
    # elapsed = (time.time() - start)
    print "prepare_merge.create_job_array_script(command_name, its) = %s,  time: %s" % (command_name, elapsed)

  