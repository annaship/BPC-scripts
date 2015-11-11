import fileinput
import re
import sys, getopt

def usage():
  print '''test.py -i <inputfile> [-o <outputfile> -v -l]
           -i <inputfile>
           -o <outputfile> (default "out_region.tsv)"
           -v verbose
           -l refhvr_cut length (default = 50)
           -f <f_primer> (default "TTGTACACACCGCCC" v9 1389F)
           -r <r_primer> (default "GTAGGTGAACCTGC.GAAGG" v9 1510R)
           '''  
           

def main(argv):
    inputfile  = ''
    outputfile = 'out_region.tsv'
    verbose    = False
    min_refhvr_cut_len = 50
    f_primer   = "TTGTACACACCGCCC"
    r_primer   = "GTAGGTGAACCTGC.GAAGG"
    
    try:
      opts, args = getopt.getopt(argv, "hvli:o:f:r:", ["ifile=", "ofile=", "f_primer=", "r_primer="])
      # print "opts = %s, args = %s" % (opts, args)
    except getopt.GetoptError:
      sys.exit(2)
      
    for opt, arg in opts:
      if opt == "-v":
        verbose = True
      elif opt == '-l':
        min_refhvr_cut_len = 0
      elif opt == '-h':
        usage()
        sys.exit()
      elif opt in ("-i", "--ifile"):
        inputfile = arg
      elif opt in ("-o", "--ofile"):
        outputfile = arg
      elif opt in ("-f", "--f_primer"):
        f_primer = arg
      elif opt in ("-r", "--r_primer"):
        r_primer = arg
              
    print "min_refhvr_cut_len = %s" % min_refhvr_cut_len
    return (inputfile, outputfile, verbose, min_refhvr_cut_len, f_primer, r_primer)


def read_file(inputfile):
  with open (inputfile, "r") as myfile:
    return myfile.readlines()

def open_file_to_write(outputfile):
  f = open(outputfile, 'w')
  return f

def print_stats(sequence, refhvr_cut, f_primer, r_primer):  
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
    

def get_region(sequence, f_primer, r_primer):
  refhvr_cut_t = ()
  refhvr_cut = ""
  
  re_f_primer = '^.+' + f_primer
  
  re_r_primer = r_primer + '.+'
  
  hvrsequence_119_1_t = re.subn(re_f_primer, '', sequence)
  # print hvrsequence_119_1_t
  if (hvrsequence_119_1_t[1] > 0):
    refhvr_cut_t = re.subn(re_r_primer, '', hvrsequence_119_1_t[0])
    print refhvr_cut_t
    if (refhvr_cut_t[1] > 0):
      refhvr_cut = refhvr_cut_t[0]
    else:
      if (verbose):
        print "Can't find reverse primer %s in %s" % (r_primer, sequence)
      refhvr_cut = ""
    
  else:
    if (verbose):
      print "Can't find forward primer %s in %s" % (f_primer, sequence)
    refhvr_cut = ""
    
  return refhvr_cut
    

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

    
# 467540	2	ACCTGAGTGCTATTGGGTTTGCTAAAGACATGCAAGTGGAATGTCTCTTCGGAGGCATCGCGAAAGGCTCAGTAACACGTCGCCAATCTGCCCTGTGGACGGGAATAACCTCGGGAAACTGAGACTAATCCCCGATAAGTATGGACTCCTGGAAAGGGCCAATATTTAATGGTCTTCGGATCGCCACAGGATGAGGCCGCGGCCGATTAGCTAGTAAGTGATGTAACGGATCACTTAGGCATTGATCGGTAGGGGCTATGAGAGTAGGAGCCCCGAGAAGGACACTTAGACACTGGTCCTAGCACTACGGTGTGCAGCAGTCGGGAATCGTGCCCAATGCGCGAAAGCGTGAGGCCGCGAACCCAAGTGCTAGGGTTACCCCCTAGCTGTGATGGAGTGTTTAAAGCTCTAACAGCAAGCAGAGGGCAAGGGTGGTGCCAGCCGCCGCGGTAAAACCAGCTCTGCGAGTGCTCAGGACGATTATTGGGCTTAAAGCATCCGTAGCCGGGTAAGTAGGTCCCTGATCAAATCTGCAAGCTTAACTTGTAGGCTGTCAAGGATACCACTAACCTAGGGAATAGGAGAGGTGAACGGTACTGCGAGAGAAGCGGTGAAATGCGTTGATTCTCGCAGGACCCACAGTGGCGAAGGCGGTTCACTGGAATATCTCCGACGGTGATGGATGAAAGCCAGGGGAGCGAAAGGGATTAGAGACCCCTGTAGTCCTGGCCGTAAACGATGAGGATTAGGTGTTGGTTATGGCTAAAGGGCCTGATCAGTGCCAAAGGGAAACTATTAAATCCTCCGCCTGGGGAGTACGGTCGCAAGGCTGAAACTTAAATGAATTGACGGGAAAGCGCCACAAGGCACGGGATGTGTGGTTTAATTCGACTCAACGCGAGGAAACTCACCTGGGGCGACTGTTAAATGTGAGTCAGGCTGAAGACCTTACTCGAATAAAACAGAGAGGTAGTGCATGGCCGTCTCAAGCTCGTGCCGTGAGGTGTGCTCTTAAGTGAGTAAACGAGCGAGACCCGCGTCCCTATTTGCTAAGAGCAAGCTTCGGCTTGGCTGAGGACAATAGGGAGATCGCTATCGATGAAGATAGATGAAAGGGCGGGCCACGGCAGGTCAGTATGCTCCTAATCCCCAGGGCCACACACGCATCACAATGAGTAGGACAATGAGAGGCGACCCCGAAAGGGGAAGCGGACCCCCAAACCTGCTCGCAGTAGGGATCGAGGTCTGTAACCGACCTCGTGAACATGGAGCGCCTAGTATCCGTGTGTCATCATCGCACGGAGAATACGTCCCCGCTTTTTGTACACACCGCCCGTCGTTGCAACGAAGTGAGGTTCGGTTGAGGTTGGGCTGTTACAGCTTATTCGAAATTGGGCTTCGCGACGATGCAA

if __name__ == "__main__":
    (inputfile, outputfile, verbose, min_refhvr_cut_len, f_primer, r_primer) = main(sys.argv[1:])
    print 'Input file  is "%s"' % inputfile
    print 'Output file is "%s"' % outputfile
    print 'Forward primer is "%s"' % f_primer
    print 'Reverse primer is "%s"' % r_primer

    inputfile_content = read_file(inputfile)
    open_outputfile   = open_file_to_write(outputfile)   

    for line in inputfile_content:
      refhvr_cut = process(line.strip(), verbose, f_primer, r_primer)
      if (len(refhvr_cut) > int(min_refhvr_cut_len)):
        open_outputfile.write(refhvr_cut)
        open_outputfile.write("\n")
      
    open_outputfile.close()
