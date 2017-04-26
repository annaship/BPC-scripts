"""
https://gist.github.com/mdshw5/c7cf7a232b27de0d4b31#file-fasta_to_fastq-py
Convert FASTA to FASTQ file with a static
Usage:
$ ./fasta_to_fastq NAME.fasta NAME.fastq
"""

import sys, os
# from Bio import SeqIO
import IlluminaUtils.lib.fastalib as fa
import IlluminaUtils.lib.fastqlib as fq

# Get inputs
fa_path = sys.argv[1]
qual_path = sys.argv[2]
fq_path = sys.argv[3]

"""
TODO:
args
no qual (40)
w qual
"""
def make_a_dict(f_path):
  id_dict = {}
  while f_path.next_regular():
    id = f_path.id
    id_dict[id] = f_path.seq
  f_path.reset()
  return id_dict

f_input = fa.SequenceSource(fa_path)
f_qual = fa.SequenceSource(qual_path)

f_input_dict = make_a_dict(f_input)
f_qual_dict = make_a_dict(f_qual)

# print "f_input_dict"
# print f_input_dict
# print "f_qual_dict"
# print f_qual_dict

def convert_qual_scores(line):
  res = []
  arr = line.split(" ")
  for num in arr:
    ch = chr(int(num) + 33)
    # print ch
    res.append(ch)
  return "".join(res)
    

with open(fq_path, "w") as fastq:
  for id, seq in f_input_dict.items():
    q = convert_qual_scores(f_qual_dict[id])
    # q = "".join(40 * len(f_qual_dict[id]))
    line = "@%s\n%s\n+\n%s\n" % (id.strip(), seq.strip(), q.strip()) 
    fastq.write(line)
  


#   print
  # output.write(input.id + "#" + input.seq + "\n")


"""    def process_Q_list(self):
        if self.CASAVA_version == '1.8':
            self.Q_list = [ord(q) - 33 for q in self.qual_scores]
        else:
            self.Q_list = [ord(q) - 64 for q in self.qual_scores]
 
        return self.Q_list
"""

# make fastq
"""with open(fa_path, "r") as fasta, open(qual_path, "r") as qual, open(fq_path, "w") as fastq:
    for record in SeqIO.parse(fasta, "fasta"):
      print "record"
      print record
      for entry in qual:
        if not entry.startswith(">"):
          print entry
          record.letter_annotations["phred_quality"] = [40] * len(record)
          SeqIO.write(record, fastq, "fastq")
  """      
        
"""
def process_Q_list(self):
  if self.CASAVA_version == '1.8':
      self.Q_list = [ord(q) - 33 for q in self.qual_scores]
  else:
      self.Q_list = [ord(q) - 64 for q in self.qual_scores]

  return self.Q_list

"""