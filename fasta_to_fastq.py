"""
https://gist.github.com/mdshw5/c7cf7a232b27de0d4b31#file-fasta_to_fastq-py
Convert FASTA to FASTQ file with a static
Usage:
$ ./fasta_to_fastq NAME.fasta NAME.fastq
"""

import sys, os
# from Bio import SeqIO
import IlluminaUtils.lib.fastalib as fa

# Get inputs
fa_path = sys.argv[1]
qual_path = sys.argv[2]
fq_path = sys.argv[3]


# def init_unique_hash(self):
#     while self.next_regular():
#         hash = hashlib.sha1(self.seq.upper()).hexdigest()
#         if hash in self.unique_hash_dict:
#             self.unique_hash_dict[hash]['ids'].append(self.id)
#             self.unique_hash_dict[hash]['count'] += 1
#         else:
#             self.unique_hash_dict[hash] = {'id' : self.id,
#                                            'ids': [self.id],
#                                            'seq': self.seq,
#                                            'count': 1}
#
#     self.unique_hash_list = [i[1] for i in sorted([(self.unique_hash_dict[hash]['count'], hash)\
#                     for hash in self.unique_hash_dict], reverse = True)]
#
#
#     self.total_unique = len(self.unique_hash_dict)
#     self.reset()

f_input = fa.SequenceSource(fa_path)
f_qual = fa.SequenceSource(qual_path)
f_input.init_unique_hash()
# while f_input.next():
#   fa.init_unique_hash()

f_input_dict = f_input.unique_hash_dict.items()
f_qual_dict = f_qual.unique_hash_dict.items()
# print f_input.total_unique
# print f_qual.total_unique

print "f_input_dict"
print f_input_dict
print "f_qual_dict"
print f_qual_dict

#   print
  # output.write(input.id + "#" + input.seq + "\n")
  

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