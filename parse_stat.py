#! /bioware/python-2.7.5/bin/python

# read merge stat files for Illumina and get statistics in one file
# Number of pairs analyzed      149888
# Prefix failed in Pair 1       1774
# Prefix failed in Pair 2       4783
# Prefix failed in both         224
# Passed prefix total           143555
# Failed prefix total           6333
# Merged total                  137955
# Merge failed total            5524
# Merge eliminated due to Ns    76

# USAGE: parse_stat.py 

import sys
import os

def find_all_files():
    # todo: path = args
    path = "."
    all_stat_file_names = []
    for dir_entry in os.listdir(path):
        if dir_entry.endswith("STATS"):
            dir_entry_path = os.path.join(path, dir_entry)
            if os.path.isfile(dir_entry_path):
                all_stat_file_names.append(dir_entry)
    return all_stat_file_names

def parse_line(line, stat_data):
    line = line.strip()
    text   = line.split("\t")
    try:
        stat_data[text[0].strip()] = text[1].strip()
    except:
        print 'Error'        
    return stat_data

def make_output_file(output_file_base):
    output_file_name = output_file_base + ".csv"
    try:
        output = open(output_file_name, 'w')        
    except IOError:
        print 'Error: You have no permission to write destination: "%s"'\
                    % output_file_name
        sys.exit(-1)
    return output
    
def make_stat_cnts(stat_data):
    stat_counts = {}
    # reads_deleted_not_chimera_cnt = Number of pairs analyzed - Merged total = Failed prefix total + Merge failed total + Merge eliminated due to Ns
    stat_counts["total_raw_reads_cnt"]           = stat_data["Number of pairs analyzed"]    
    stat_counts["reads_deleted_not_chimera_cnt"] = str(int(stat_data["Number of pairs analyzed"]) - int(stat_data["Merged total"]))
    stat_counts["merged_total"]             = stat_data["Merged total"]    
    return stat_counts

def main(args):
    stat_names  = ["Number of pairs analyzed", "Prefix failed in Pair 1", "Prefix failed in Pair 2", "Prefix failed in both", "Passed prefix total", "Failed prefix total", "Merged total", "Merge failed total", "Merge eliminated due to Ns"]
    stat_data   = {}
    stat_counts = {}
    all_stat_file_names = find_all_files()
    output              = make_output_file("output") 
    output.write('"id", "run_key", "barcode_index", "total_raw_reads_cnt", "total_deleted", "reads_deleted_not_chimera_cnt", "chimeras_cnt", "merged_total"\n')
       
    for input_file_name in all_stat_file_names:
        # todo: get project_dataset from db
        
        barcode_index, run_key = input_file_name.split("_")[0:2] 
        
        for line in open(input_file_name):
            if (line.split("\t")[0].strip() in stat_names):
                stat_data = parse_line(line, stat_data)
                
        # print make_stat_cnts(stat_data)
        # {'reads_deleted_not_chimera_cnt': 3807, 'merged_total': '34630', 'total_raw_reads_cnt': '38437'}
        
        stat_counts = make_stat_cnts(stat_data)
        output.write((", %s, %s, %s, , %s, , %s\n") % (run_key, barcode_index, stat_counts["total_raw_reads_cnt"], stat_counts["reads_deleted_not_chimera_cnt"], stat_counts["merged_total"]))
                
    output.close()

if __name__ == '__main__':
    # import argparse
    # 
    # parser = argparse.ArgumentParser(description='Please provide a path to STATS files to make a combine csv')
    # parser.add_argument('-p', '--path', metavar = 'INPUT_dir', default = ".",
    #                         help = 'STATS files directory')
    # parser.add_argument('-o', '--output-file', metavar = 'OUTPUT_file', default = None,
    #                         help = 'file to store the combine statistics')
    # 
    # args = parser.parse_args()
    args = ""
    main(args)
    
