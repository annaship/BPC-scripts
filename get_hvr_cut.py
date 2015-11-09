import fileinput

def process(line):
    print line


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
