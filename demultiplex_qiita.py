import fileinput
import re
import sys, getopt
import collections
import IlluminaUtils.lib.fastalib as fastalib

# class FastaFiles:


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

def make_file_names(headlines_dict):
  return [headline.split("_")[0] + ".fa" for headline in headlines_dict]

def open_out_sample_files(inputfile_content_ids):
    sample_names = make_file_names(inputfile_content_ids)
    out_files = {}
    for sample in sample_names:
      out_files[sample] = open(sample, "a")
    # out_files = dict([(sample, fastalib.FastaOutput(sample)) for sample in sample_names])
    return out_files

def close_sample_files(out_files):
    [o_file[1].close() for o_file in out_files.items()] 
    return

def write_id(opened_file, id):
    opened_file.write('>%s\n' % id)

def write_seq(opened_file, seq):
    opened_file.write('%s\n' % seq)
    
if __name__ == "__main__":
    (inputfile) = get_args(sys.argv[1:])
    print 'Input file is "%s"' % inputfile
    
    inputfile_content = fastalib.ReadFasta(inputfile)

    out_files = open_out_sample_files(inputfile_content.ids)
    # print out_files
    
    fa_dictionary = dict(zip(inputfile_content.ids, inputfile_content.sequences))
    for id, seq in fa_dictionary.items():
      file_name = id.split("_")[0] + ".fa"
      # fastalib.FastaOutput(file_name).write_id(id)
      # fastalib.FastaOutput(file_name).write_seq(seq)
      write_id(out_files[file_name], id)
      write_seq(out_files[file_name], seq)
    
    close_sample_files(out_files)
      # print fastalib.FastaOutput()
    # print dictionary
    # for out_file in out_files:
    #   
    # while inputfile_content.next()
    # print inputfile_content.ids
    # print inputfile_content.sequences

    # inputfile_content = read_file(inputfile)
    
    # open_outputfile   = open_file_to_write(outputfile)   
    # 
    # for line in inputfile_content:
    #   refhvr_cut = process(line.strip(), verbose, f_primer, r_primer)
    #   if (len(refhvr_cut) > int(min_refhvr_cut_len)):
    #     open_outputfile.write(refhvr_cut)
    #     open_outputfile.write("\n")
    #   
    # open_outputfile.close()
