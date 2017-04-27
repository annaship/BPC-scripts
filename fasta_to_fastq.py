import sys, os
import IlluminaUtils.lib.fastalib as fa
import IlluminaUtils.lib.fastqlib as fq

# Get inputs
# fa_path = sys.argv[1]
# qual_path = sys.argv[2]
# fq_path = sys.argv[3]

def parse_arguments():
  import argparse
  from argparse import RawTextHelpFormatter
  

  description = """Convert fasta files into fastq format, using quality scores from a file provided or makes a fake 40 score.
  """

  usage =  """%(prog)s -f fasta_path [-q qual_path -o output_fastq_file]
  ex: python %(prog)s -f 1.fa -q 1.qual -o 1.fastq
  """

  parser = argparse.ArgumentParser(usage = "%s" % usage, description = "%s" % description, formatter_class=RawTextHelpFormatter)

  parser.add_argument('-f'     , dest = "fa_path",    help = 'fasta file name')
  parser.add_argument('-q'     , dest = "qual_path",  help = 'quality scores file name')
  parser.add_argument('-o'     , dest = "fq_path" ,   help = 'fastq file name', nargs='?')
  parser.add_argument('-v'     , '--verbose'          , action='store_true', help = 'VERBOSITY')

  args = parser.parse_args()
  if args.fq_path is None:
    fq_path_default = os.path.splitext(args.fa_path)[0]    
    args.fq_path = fq_path_default + ".fastq"

  print "args"
  print args
  return args


"""
TODO:
args
"""
def make_a_dict(f_path):
  id_dict = {}
  while f_path.next_regular():
    id = f_path.id
    id_dict[id] = f_path.seq
  f_path.reset()
  return id_dict
  
  

args = parse_arguments()
fa_path   = args.fa_path
qual_path = args.qual_path
fq_path   = args.fq_path

"""  
TODO:
if no qual - use fake and do not process qual_path
File "fasta_to_fastq.py", line 60, in <module>
    f_qual = fa.SequenceSource(qual_path)
  File "/bioware/python-2.7.12-201701011205/lib/python2.7/site-packages/illumina_utils-1.4.8-py2.7.egg/IlluminaUtils/lib/fastalib.py", line 84, in __init__
    self.file_pointer = open(self.fasta_file_path)
TypeError: coercing to Unicode: need string or buffer, NoneType found
"""

f_input = fa.SequenceSource(fa_path)
f_qual = fa.SequenceSource(qual_path)

f_input_dict = make_a_dict(f_input)
f_qual_dict = make_a_dict(f_qual)

# print "f_input_dict"
# print f_input_dict
# print "f_qual_dict"
# print f_qual_dict

def convert_qual_scores(line):
  # res = []
  arr = line.split(" ")
  # for num in arr:
    # ch = chr(int(num) + 33)
    # # print ch
    # res.append(ch)
  res = [chr(int(num) + 33) for num in arr]
  return "".join(res)
    
def fake_qual_scores(seq):
  res = []
  ch = chr(40 + 33)
  return "".join(ch * len(seq))

with open(fq_path, "w") as fastq:
  for id, seq in f_input_dict.items():
    q = convert_qual_scores(f_qual_dict[id])
    # q = fake_qual_scores(seq)
    line = "@%s\n%s\n+\n%s\n" % (id.strip(), seq.strip(), q.strip()) 
    fastq.write(line)
  

