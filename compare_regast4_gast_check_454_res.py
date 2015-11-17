import sys
filename = sys.argv[-1]
  
def compare_res(num0, num1):
  if num0 == num1:
    return True
  else:
    return False
    
  # print line.rstrip()
  # print "num = %s" % num
  # print "total_trimseq = %s" % total_trimseq
  # print all_ok
  
    
with open(filename) as in_file:
  for line in in_file:
    if line.startswith('=========='):
      num    = 0
      print line.rstrip()
      print next(in_file).rstrip()

    elif line.startswith("total_trimseq"):
      total_trimseq = int(next(in_file))

    elif line.startswith("total_gast_2"):      
      total_gast_2 = int(next(in_file))
      print "For %s numbers (%s, %s) are equal is %s" % (line.rstrip(), total_trimseq, total_gast_2, compare_res(total_trimseq, total_gast_2))

    elif line.startswith("total_gast_trimseq"):
      total_gast_trimseq = int(next(in_file))
      print "For %s numbers (%s, %s) are equal is %s" % (line.rstrip(), total_gast_2, total_gast_trimseq, compare_res(total_gast_2, total_gast_trimseq))
            
    elif line.startswith("total_gast_concat_trimseq"):
      total_gast_concat_trimseq = int(next(in_file))
      print "For %s numbers (%s, %s) are equal is %s" % (line.rstrip(), total_gast_trimseq, total_gast_concat_trimseq, compare_res(total_gast_trimseq, total_gast_concat_trimseq))
