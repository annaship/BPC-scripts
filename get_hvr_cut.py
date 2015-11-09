import fileinput
import re
import sys
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
#   
#     searchObj = re.search('TTGTACACACCGCCC', sequence)
#     print "re.search('TTGTACACACCGCCC', sequence) = "
#     if searchObj:
#        print "searchObj.group() : ", searchObj.group()
#     else:
#         print "forward primer not found!!"
#        
#     hvrsequence_119_1 = re.sub('^.+TTGTACACACCGCCC', '', sequence)
#     start1 = re.search('TTGTACACACCGCCC', sequence).start()
#     print "hvrsequence_119_1 = %s, start = %s\n---" % (hvrsequence_119_1, start1)
# 
# # ===
# 
#     searchObj2 = re.search('GTAGGTGAACCTGC.GAAG', hvrsequence_119_1)
#     print "re.search('GTAGGTGAACCTGC.GAAGG', hvrsequence_119_1) = "
#     if searchObj2:
#        print "searchObj2.group() : ", searchObj2.group()
#     else:
#        print "reverse primer not found!!"
# 
#     hvrsequence_119_2 = re.sub('GTAGGTGAACCTGC.GAAGG.+', '', hvrsequence_119_1)
#     print "hvrsequence_119_2 = %s" % (hvrsequence_119_2)
# 
#     start2 = re.search('GTAGGTGAACCTGC.GAAGG', sequence).start()
#     len_cut = len(hvrsequence_119_2)
#     print "re.search('GTAGGTGAACCTGC.GAAGG', sequence).start() = %s, len_cut = %s" % (start2, len_cut)
    
    # f_primer = find_primer(hvrsequence_119, "TTGTACACACCGCCC")
    print "refssu_name_id = %s, clean_taxonomy_id = %s, hvrsequence_119 = %s\n===" % (refssu_name_id, clean_taxonomy_id, sequence)
    # 
# def find_primer(hvrsequence_119, primer):
#     matchObj = re.match( r'primer', hvrsequence_119)
#     print "matchObj = %s" % matchObj

    
# 467540	2	ACCTGAGTGCTATTGGGTTTGCTAAAGACATGCAAGTGGAATGTCTCTTCGGAGGCATCGCGAAAGGCTCAGTAACACGTCGCCAATCTGCCCTGTGGACGGGAATAACCTCGGGAAACTGAGACTAATCCCCGATAAGTATGGACTCCTGGAAAGGGCCAATATTTAATGGTCTTCGGATCGCCACAGGATGAGGCCGCGGCCGATTAGCTAGTAAGTGATGTAACGGATCACTTAGGCATTGATCGGTAGGGGCTATGAGAGTAGGAGCCCCGAGAAGGACACTTAGACACTGGTCCTAGCACTACGGTGTGCAGCAGTCGGGAATCGTGCCCAATGCGCGAAAGCGTGAGGCCGCGAACCCAAGTGCTAGGGTTACCCCCTAGCTGTGATGGAGTGTTTAAAGCTCTAACAGCAAGCAGAGGGCAAGGGTGGTGCCAGCCGCCGCGGTAAAACCAGCTCTGCGAGTGCTCAGGACGATTATTGGGCTTAAAGCATCCGTAGCCGGGTAAGTAGGTCCCTGATCAAATCTGCAAGCTTAACTTGTAGGCTGTCAAGGATACCACTAACCTAGGGAATAGGAGAGGTGAACGGTACTGCGAGAGAAGCGGTGAAATGCGTTGATTCTCGCAGGACCCACAGTGGCGAAGGCGGTTCACTGGAATATCTCCGACGGTGATGGATGAAAGCCAGGGGAGCGAAAGGGATTAGAGACCCCTGTAGTCCTGGCCGTAAACGATGAGGATTAGGTGTTGGTTATGGCTAAAGGGCCTGATCAGTGCCAAAGGGAAACTATTAAATCCTCCGCCTGGGGAGTACGGTCGCAAGGCTGAAACTTAAATGAATTGACGGGAAAGCGCCACAAGGCACGGGATGTGTGGTTTAATTCGACTCAACGCGAGGAAACTCACCTGGGGCGACTGTTAAATGTGAGTCAGGCTGAAGACCTTACTCGAATAAAACAGAGAGGTAGTGCATGGCCGTCTCAAGCTCGTGCCGTGAGGTGTGCTCTTAAGTGAGTAAACGAGCGAGACCCGCGTCCCTATTTGCTAAGAGCAAGCTTCGGCTTGGCTGAGGACAATAGGGAGATCGCTATCGATGAAGATAGATGAAAGGGCGGGCCACGGCAGGTCAGTATGCTCCTAATCCCCAGGGCCACACACGCATCACAATGAGTAGGACAATGAGAGGCGACCCCGAAAGGGGAAGCGGACCCCCAAACCTGCTCGCAGTAGGGATCGAGGTCTGTAACCGACCTCGTGAACATGGAGCGCCTAGTATCCGTGTGTCATCATCGCACGGAGAATACGTCCCCGCTTTTTGTACACACCGCCCGTCGTTGCAACGAAGTGAGGTTCGGTTGAGGTTGGGCTGTTACAGCTTATTCGAAATTGGGCTTCGCGACGATGCAA

for line in fileinput.input():
    process(line)

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
