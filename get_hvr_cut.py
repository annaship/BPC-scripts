import fileinput
import re
import sys, getopt

def usage():
  print 'test.py -i <inputfile> -o <outputfile> [-v]'  

def main(argv):
    inputfile  = ''
    outputfile = 'out_region.tsv'
    verbous    = ''
    
    try:
      opts, args = getopt.getopt(argv, "hvi:o:", ["ifile=","ofile="])
      # print "opts = %s, args = %s" % (opts, args)
    except getopt.GetoptError:
      sys.exit(2)
      
    for opt, arg in opts:
      if opt == "-v":
        verbose = True
      if opt == '-h':
        usage()
        sys.exit()
      elif opt in ("-i", "--ifile"):
        inputfile = arg
      elif opt in ("-o", "--ofile"):
        outputfile = arg
        
      return (inputfile, outputfile, verbous)


def read_file():
  f = open('workfile', 'r')
  f.read()


def get_region(sequence):
  hvrsequence_119_1 = re.sub('^.+TTGTACACACCGCCC', '', sequence)
  
  print "Full length sequence: %s" % len(sequence)
  print "Forward primer starts: %s" % re.search('TTGTACACACCGCCC', sequence).start()
  print "Reverse primer starts: %s" % re.search('GTAGGTGAACCTGC.GAAGG', sequence).start()
  v9_cut = re.sub('GTAGGTGAACCTGC.GAAGG.+', '', hvrsequence_119_1)
  print "v9 length: %s" % len(v9_cut)
  
  return v9_cut

def process(line):
    # print line
    refssu_name_id    = line.split("\t")[0]
    clean_taxonomy_id = line.split("\t")[1]
    sequence          = line.split("\t")[2]
    
    v9_cut = get_region(sequence)
    print "v9_cut = %s" % v9_cut


    print "refssu_name_id = %s, clean_taxonomy_id = %s, hvrsequence_119 = %s\n===" % (refssu_name_id, clean_taxonomy_id, sequence)

    
# 467540	2	ACCTGAGTGCTATTGGGTTTGCTAAAGACATGCAAGTGGAATGTCTCTTCGGAGGCATCGCGAAAGGCTCAGTAACACGTCGCCAATCTGCCCTGTGGACGGGAATAACCTCGGGAAACTGAGACTAATCCCCGATAAGTATGGACTCCTGGAAAGGGCCAATATTTAATGGTCTTCGGATCGCCACAGGATGAGGCCGCGGCCGATTAGCTAGTAAGTGATGTAACGGATCACTTAGGCATTGATCGGTAGGGGCTATGAGAGTAGGAGCCCCGAGAAGGACACTTAGACACTGGTCCTAGCACTACGGTGTGCAGCAGTCGGGAATCGTGCCCAATGCGCGAAAGCGTGAGGCCGCGAACCCAAGTGCTAGGGTTACCCCCTAGCTGTGATGGAGTGTTTAAAGCTCTAACAGCAAGCAGAGGGCAAGGGTGGTGCCAGCCGCCGCGGTAAAACCAGCTCTGCGAGTGCTCAGGACGATTATTGGGCTTAAAGCATCCGTAGCCGGGTAAGTAGGTCCCTGATCAAATCTGCAAGCTTAACTTGTAGGCTGTCAAGGATACCACTAACCTAGGGAATAGGAGAGGTGAACGGTACTGCGAGAGAAGCGGTGAAATGCGTTGATTCTCGCAGGACCCACAGTGGCGAAGGCGGTTCACTGGAATATCTCCGACGGTGATGGATGAAAGCCAGGGGAGCGAAAGGGATTAGAGACCCCTGTAGTCCTGGCCGTAAACGATGAGGATTAGGTGTTGGTTATGGCTAAAGGGCCTGATCAGTGCCAAAGGGAAACTATTAAATCCTCCGCCTGGGGAGTACGGTCGCAAGGCTGAAACTTAAATGAATTGACGGGAAAGCGCCACAAGGCACGGGATGTGTGGTTTAATTCGACTCAACGCGAGGAAACTCACCTGGGGCGACTGTTAAATGTGAGTCAGGCTGAAGACCTTACTCGAATAAAACAGAGAGGTAGTGCATGGCCGTCTCAAGCTCGTGCCGTGAGGTGTGCTCTTAAGTGAGTAAACGAGCGAGACCCGCGTCCCTATTTGCTAAGAGCAAGCTTCGGCTTGGCTGAGGACAATAGGGAGATCGCTATCGATGAAGATAGATGAAAGGGCGGGCCACGGCAGGTCAGTATGCTCCTAATCCCCAGGGCCACACACGCATCACAATGAGTAGGACAATGAGAGGCGACCCCGAAAGGGGAAGCGGACCCCCAAACCTGCTCGCAGTAGGGATCGAGGTCTGTAACCGACCTCGTGAACATGGAGCGCCTAGTATCCGTGTGTCATCATCGCACGGAGAATACGTCCCCGCTTTTTGTACACACCGCCCGTCGTTGCAACGAAGTGAGGTTCGGTTGAGGTTGGGCTGTTACAGCTTATTCGAAATTGGGCTTCGCGACGATGCAA

if __name__ == "__main__":
   (inputfile, outputfile, verbous) = main(sys.argv[1:])
   print 'Input file is "%s"' % inputfile
   print 'Output file is "%s"' % outputfile
   

# for line in fileinput.input():
#     read_file()
#     process(line)

#     line      = line.strip()
#     
#     # >AJ440719.1.1458 Bacteria;Cyanobacteria;Chloroplast;putative agent of rhinosporidiosis
#     
#     output_line1 = ""
#     output_line2 = ""
#     first_part  = ""
#     sec_part    = ""
#     add_seq     = ""
# 
#     # AJ440719|1|1458|Bacteria;Cyanobacteria;Chloroplast;putative agent of rhinosporidiosis
#     
#     if line.startswith('>'):
#       first_part  = line.split()[0]
#       sec_part    = line.split()[1:]
#       output_line1 = first_part.strip('>')
#       f.write(output_line1) # python will convert \n to os.linesep
#       
#       print output_line1
#       # add_seq = add_seq + output_line.strip("\n")
#     else:
#       # output_line2 = line.strip(".") # wrong, makes different length!
#       output_line2 = line.replace(".", "-").replace("U", "T")
#       #output_line2 = line.replace("U", "T")
#       f.write("|" + output_line2 + "\n")
#       
#       # print output_line2
#       # print "\n%s|%s" % (output_line1, output_line2)
# 
# #     if not (prev == current):
# #            out_line.append(current)
# #        prev = tt
# 
# #    output_line = ";".join(out_line)
#     
# #    if (line != output_line) and (not line.startswith("Eukarya")): 
# #        print '"%s"\t"%s"' % (line, output_line)
# 
# 
# f.close() # you can omit in most cases as the destructor will call if
# 
