"""
https://gist.github.com/mdshw5/c7cf7a232b27de0d4b31#file-fasta_to_fastq-py
Convert FASTA to FASTQ file with a static
Usage:
$ ./fasta_to_fastq NAME.fasta NAME.fastq
"""

import sys, os
from Bio import SeqIO

# Get inputs
fa_path = sys.argv[1]
qual_path = sys.argv[2]
fq_path = sys.argv[3]

# make fastq
with open(fa_path, "r") as fasta, open(qual_path, "r") as qual, open(fq_path, "w") as fastq:
    for record in SeqIO.parse(fasta, "fasta"):
      print "record"
      print record
      for entry in qual:
        if not entry.startswith(">"):
          print entry
          record.letter_annotations["phred_quality"] = [40] * len(record)
          SeqIO.write(record, fastq, "fastq")
        
        
        """
        def process_Q_list(self):
            if self.CASAVA_version == '1.8':
                self.Q_list = [ord(q) - 33 for q in self.qual_scores]
            else:
                self.Q_list = [ord(q) - 64 for q in self.qual_scores]
 
            return self.Q_list
        
        """