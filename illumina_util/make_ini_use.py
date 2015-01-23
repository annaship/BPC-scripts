import os
from make_ini_class import CreateIniFiles

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='''Makes ini files for demultiplexed Illumina fastq per barcode from "in_barcode_file_name"
    Command line example: python make_ini_use.py  --in_barcode_file_name "prep_template.txt"  --pair_1_prefix "........CTACCTGCGGA[AG]GGATCA" --pair_2_prefix "GAGATCC[AG]TTG[CT]T[AG]AAAGTT" --input_dir "results" --out_file_path "results"
    ''')
    # todo: add user_config
    # parser.add_argument('--user_config', metavar = 'CONFIG_FILE',
    #                                     help = 'User configuration to run')
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
    
    parser.add_argument('--out_file_path', default = "",
                                        help = 'Output directory. Default is res_\{input_dir\}. Must exist.')
    
    parser.add_argument('--input_dir', default = ".",
                                        help = 'Input directory. Default is %(default)d.')
    
    parser.add_argument('--in_barcode_file_name',
                                        help = 'Tab delimited file with sample names in the first column and its barcode in the second.')

    args = parser.parse_args()
    
    create_ini_files = CreateIniFiles(args)

    # todo: DRY! The same in demultiplex_class.py
    create_ini_files.get_file_name_by_barcode_from_prep()
    print "create_ini_files.get_file_name_by_barcode_from_prep()"

    create_ini_files.create_inis()
    print "create_ini_files.create_inis()"
    
    # command_name = "merge-illumina-pairs"
    # 
    # illumina_files.create_job_array_script(command_name)
    # print "illumina_files.create_job_array_script(command_name, its) = %s,  time: %s" % (command_name, elapsed)

