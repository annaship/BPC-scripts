import fileinput
import re
import sys, getopt
import collections

def usage():
  print '''test.py -i <inputfile>
           '''  


def get_args(argv):
    inputfile  = ''
  
    try:
      opts, args = getopt.getopt(argv, "hi:", ["ifile="])
      print "opts = %s, args = %s" % (opts, args)
    except getopt.GetoptError:
      sys.exit(2)
      
    for opt, arg in opts:
      if opt == '-h':
        usage()
        sys.exit()
      elif opt in ("-i", "--ifile"):
        inputfile = arg
              
    # print "min_refhvr_cut_len = %s" % min_refhvr_cut_len
    return (inputfile)

def make_fa_dict(file_content):
  for line in file_content:
      print line
      print i
      i += 1
      if line.startswith(">"):
        k = line.strip().lstrip(">")
        next
      else:
        fa_dict[k] = line.strip()
  return fa_dict

def make_sammple_dict():
  sample_dict = collections.defaultdict(lambda: collections.defaultdict(list))
  for head, seq in fa_dict.items():
    print head
    print seq
    sample_name = head.split("_")[0]
    print sample_name
    sample_dict[sample_name][head] = seq
  return sample_dict

def read_file(inputfile):
  with open (inputfile, "r") as myfile:
    return myfile.readlines()

def open_file_to_write(outputfile):
  f = open(outputfile, 'w')
  return f

def make_output_line(line, refhvr_cut):
    refssu_name_id    = line.split("\t")[0]
    clean_taxonomy_id = line.split("\t")[1]
    return refssu_name_id + "\t" + clean_taxonomy_id + "\t" + refhvr_cut

def process(line, verbose, f_primer, r_primer):
    refhvr_cut = ""
    sequence   = line.split("\t")[2]       
    refhvr_cut = get_region(sequence, f_primer, r_primer)

    if (verbose):
      print_stats(sequence, refhvr_cut, f_primer, r_primer)
    
    return make_output_line(line, refhvr_cut)
    
    # print "refssu_name_id = %s, clean_taxonomy_id = %s, hvrsequence_119 = %s\n===" % (refssu_name_id, clean_taxonomy_id, sequence)

if __name__ == "__main__":
    (inputfile) = get_args(sys.argv[1:])
    print 'Input file is "%s"' % inputfile

    inputfile_content = read_file(inputfile)
    
    # open_outputfile   = open_file_to_write(outputfile)   
    # 
    # for line in inputfile_content:
    #   refhvr_cut = process(line.strip(), verbose, f_primer, r_primer)
    #   if (len(refhvr_cut) > int(min_refhvr_cut_len)):
    #     open_outputfile.write(refhvr_cut)
    #     open_outputfile.write("\n")
    #   
    # open_outputfile.close()

# ===
# file_content = read_file(inputfile)
# fa_dict = {}
# for line in file_content:
#     print line
#     print i
#     i += 1
#     if line.startswith(">"):
#       k = line.strip().lstrip(">")
#       next
#     else:
#       fa_dict[k] = line.strip()
# print fa_dict

# sample_dict = collections.defaultdict(lambda: collections.defaultdict(list))
# for head, seq in fa_dict.items():
#   print head
#   print seq
#   sample_name = head.split("_")[0]
#   print sample_name
#   sample_dict[sample_name][head] = seq
# 
# print sample_dict