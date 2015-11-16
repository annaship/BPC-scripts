import sys
filename = sys.argv[-1]

def same_n(num0, num1):
  print "num0 %s, num1 %s" % (num0, num1)
  is_same = False
  if num0 == num1:
    is_same = True
    return is_same
    
def compare_res():
  total_trimseq = int(next(in_file))
  
  if same_n(num, total_trimseq):
    all_ok = True
  else:
    all_ok = False
  
    
with open(filename) as in_file:
  all_ok = False
  num    = 0
  name   = ""
  for line in in_file:
    if line.startswith('=========='):
      num    = 0
      name   = next(in_file)
      print line.rstrip()
      # print name
      all_ok = False
      # print "num = %s" % num
      
    elif line.startswith("total_trimseq"):
      total_trimseq = int(next(in_file))
      
      if same_n(num, total_trimseq):
        all_ok = True
      else:
        all_ok = False
        # print "For %s numbers are equal is %s" % (line.rstrip(), all_ok)
        
      # print line.rstrip()
      # print "num = %s" % num
      # print "total_trimseq = %s" % total_trimseq
      # print all_ok

    elif line.startswith("total_gast_200"):
      total_gast_200 = int(next(in_file))
      
      if same_n(total_trimseq, total_gast_200):
        all_ok = True
      else:
        all_ok = False
        print "For %s numbers are equal is %s" % (line.rstrip(), all_ok)
      # print line.rstrip()
      # print "total_trimseq = %s" % total_trimseq
      # print "total_gast_200 = %s" % total_gast_200
      
      # print all_ok
        
    elif line.startswith("total_gast_trimseq"):
      total_gast_trimseq = int(next(in_file))
      if same_n(total_gast_200, total_gast_trimseq):
        all_ok = True
      else:
        all_ok = False
        print "For %s numbers are equal is %s" % (line.rstrip(), all_ok)
      # print line.rstrip()
      # print "total_gast_trimseq = %s" % total_gast_trimseq
      # print "total_gast_200 = %s" % total_gast_200
      # print all_ok
      
    elif line.startswith("total_gast_concat_trimseq"):
      total_gast_concat_trimseq = int(next(in_file))
      if same_n(total_gast_trimseq, total_gast_concat_trimseq):
        all_ok = True
        print "For %s all numbers are equal: %s" % (line.rstrip(), all_ok)
      else:
        all_ok = False
        print "For %s numbers are equal is %s" % (line.rstrip(), all_ok)
      # print line.rstrip()
      # print "total_gast_trimseq = %s" % total_gast_trimseq
      # print "total_gast_concat_trimseq = %s" % total_gast_concat_trimseq
      # print all_ok
