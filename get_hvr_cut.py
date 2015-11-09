import fileinput
import re
import sys, getopt

def usage():
  print 'test.py -i <inputfile> [-o <outputfile> (default "out_region.tsv") -v]'  

def main(argv):
    inputfile  = ''
    outputfile = 'out_region.tsv'
    verbose    = False
    
    try:
      opts, args = getopt.getopt(argv, "hvi:o:", ["ifile=","ofile="])
      # print "opts = %s, args = %s" % (opts, args)
    except getopt.GetoptError:
      sys.exit(2)
      
    for opt, arg in opts:
      if opt == "-v":
        verbose = True
      elif opt == '-h':
        usage()
        sys.exit()
      elif opt in ("-i", "--ifile"):
        inputfile = arg
      elif opt in ("-o", "--ofile"):
        outputfile = arg
              
    return (inputfile, outputfile, verbose)


def read_file(inputfile):
  with open (inputfile, "r") as myfile:
    return myfile.readlines()

def open_file_to_write(outputfile):
  f = open(outputfile, 'w')
  return f

def print_stats(sequence, refhvr_cut):
    f_primer = "TTGTACACACCGCCC"
    r_primer = "GTAGGTGAACCTGC.GAAGG"
  
    print "Full length sequence:  %s" % len(sequence)
    try:
      print "Forward primer starts: %s" % re.search(f_primer, sequence).start()
    except AttributeError:
      print "Can't find forward primer %s in %s" % (f_primer, sequence)
      pass
    try:  
      print "Reverse primer starts: %s" % re.search(r_primer, sequence).start()
    except AttributeError:
      print "Can't find reverse primer %s in %s" % (r_primer, sequence)
      pass
    
    print "refhvr_cut = %s" % refhvr_cut
    print "refhvr cut length:     %s\n=====\n" % len(refhvr_cut)
    

def get_region(sequence):
  f_primer = "TTGTACACACCGCCC"
  r_primer = "GTAGGTGAACCTGC.GAAGG"
  refhvr_cut_t = ()
  refhvr_cut = ""
  
  hvrsequence_119_1_t = re.subn('^.+TTGTACACACCGCCC', '', sequence)
  # print hvrsequence_119_1_t
  if (hvrsequence_119_1_t[1] > 0):
    refhvr_cut_t = re.subn('GTAGGTGAACCTGC.GAAGG.+', '', hvrsequence_119_1_t[0])
    # print refhvr_cut_t
    if (refhvr_cut_t[1] > 0):
      refhvr_cut = refhvr_cut_t[0]
    else:
      print "Can't find reverse primer %s in %s" % (r_primer, sequence)
      refhvr_cut = ""
    
  else:
    print "Can't find forward primer %s in %s" % (f_primer, sequence)
    refhvr_cut = ""
    
  return refhvr_cut
    

def make_output_line(line, refhvr_cut):
    refssu_name_id    = line.split("\t")[0]
    clean_taxonomy_id = line.split("\t")[1]
    return refssu_name_id + "\t" + clean_taxonomy_id + "\t" + refhvr_cut

def process(line, verbose):
    refhvr_cut = ""
    sequence   = line.split("\t")[2]       
    refhvr_cut = get_region(sequence)

    if (verbose):
      print_stats(sequence, refhvr_cut)
    
    return make_output_line(line, refhvr_cut)
    
    # print "refssu_name_id = %s, clean_taxonomy_id = %s, hvrsequence_119 = %s\n===" % (refssu_name_id, clean_taxonomy_id, sequence)

    
# 467540	2	ACCTGAGTGCTATTGGGTTTGCTAAAGACATGCAAGTGGAATGTCTCTTCGGAGGCATCGCGAAAGGCTCAGTAACACGTCGCCAATCTGCCCTGTGGACGGGAATAACCTCGGGAAACTGAGACTAATCCCCGATAAGTATGGACTCCTGGAAAGGGCCAATATTTAATGGTCTTCGGATCGCCACAGGATGAGGCCGCGGCCGATTAGCTAGTAAGTGATGTAACGGATCACTTAGGCATTGATCGGTAGGGGCTATGAGAGTAGGAGCCCCGAGAAGGACACTTAGACACTGGTCCTAGCACTACGGTGTGCAGCAGTCGGGAATCGTGCCCAATGCGCGAAAGCGTGAGGCCGCGAACCCAAGTGCTAGGGTTACCCCCTAGCTGTGATGGAGTGTTTAAAGCTCTAACAGCAAGCAGAGGGCAAGGGTGGTGCCAGCCGCCGCGGTAAAACCAGCTCTGCGAGTGCTCAGGACGATTATTGGGCTTAAAGCATCCGTAGCCGGGTAAGTAGGTCCCTGATCAAATCTGCAAGCTTAACTTGTAGGCTGTCAAGGATACCACTAACCTAGGGAATAGGAGAGGTGAACGGTACTGCGAGAGAAGCGGTGAAATGCGTTGATTCTCGCAGGACCCACAGTGGCGAAGGCGGTTCACTGGAATATCTCCGACGGTGATGGATGAAAGCCAGGGGAGCGAAAGGGATTAGAGACCCCTGTAGTCCTGGCCGTAAACGATGAGGATTAGGTGTTGGTTATGGCTAAAGGGCCTGATCAGTGCCAAAGGGAAACTATTAAATCCTCCGCCTGGGGAGTACGGTCGCAAGGCTGAAACTTAAATGAATTGACGGGAAAGCGCCACAAGGCACGGGATGTGTGGTTTAATTCGACTCAACGCGAGGAAACTCACCTGGGGCGACTGTTAAATGTGAGTCAGGCTGAAGACCTTACTCGAATAAAACAGAGAGGTAGTGCATGGCCGTCTCAAGCTCGTGCCGTGAGGTGTGCTCTTAAGTGAGTAAACGAGCGAGACCCGCGTCCCTATTTGCTAAGAGCAAGCTTCGGCTTGGCTGAGGACAATAGGGAGATCGCTATCGATGAAGATAGATGAAAGGGCGGGCCACGGCAGGTCAGTATGCTCCTAATCCCCAGGGCCACACACGCATCACAATGAGTAGGACAATGAGAGGCGACCCCGAAAGGGGAAGCGGACCCCCAAACCTGCTCGCAGTAGGGATCGAGGTCTGTAACCGACCTCGTGAACATGGAGCGCCTAGTATCCGTGTGTCATCATCGCACGGAGAATACGTCCCCGCTTTTTGTACACACCGCCCGTCGTTGCAACGAAGTGAGGTTCGGTTGAGGTTGGGCTGTTACAGCTTATTCGAAATTGGGCTTCGCGACGATGCAA

if __name__ == "__main__":
    (inputfile, outputfile, verbose) = main(sys.argv[1:])
    print 'Input file  is "%s"' % inputfile
    print 'Output file is "%s"' % outputfile

    inputfile_content = read_file(inputfile)
    open_outputfile   = open_file_to_write(outputfile)   

    for line in inputfile_content:
      refhvr_cut = process(line.strip(), verbose)
      if (len(refhvr_cut) > 50):
        open_outputfile.write(refhvr_cut)
        open_outputfile.write("\n")
      
    open_outputfile.close()
