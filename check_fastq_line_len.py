import IlluminaUtils.lib.fastqlib as fq
import os
import sys

def get_files(walk_dir_name, ext = ""):
    files = {}
    filenames = []
    for dirname, dirnames, filenames in os.walk(walk_dir_name, followlinks=True):
        if ext:
            filenames = [f for f in filenames if f.endswith(ext)]
        
        for file_name in filenames:
            full_name = os.path.join(dirname, file_name)
            (file_base, file_extension) = os.path.splitext(os.path.join(dirname, file_name))
            files[full_name] = (dirname, file_base, file_extension)
    return files

def check_if_verb():
  try: 
    if sys.argv[2] == "-v":
      return True
  except IndexError:
    return False
  except: 
    print "Unexpected error:", sys.exc_info()[0]
    return False
  return False
  
def compare_w_score(f_input, file_name, all_dirs):
  for _ in range(50):
  #while f_input.next():
    f_input.next()
    e = f_input.entry
    seq_len = len(e.sequence)
    qual_scores_len = len(e.qual_scores)
    try:
        # print sys.argv
        if sys.argv[2] == "-q":
            print "\n=======\nCOMPARE_W_SCORE"
            print "seq_len = %s" % (seq_len)
            print "qual_scores_len = %s" % (qual_scores_len)
    except IndexError:
        pass
    except:
        raise
    # print e.header_line
    if (seq_len != qual_scores_len):
      print "WARNING, sequence and qual_scores_line have different length in %s" % file_name
      all_dirs.add(fq_files[file_name][0])


def get_seq_len(f_input, file_name, all_dirs):
  seq_lens = []
  for _ in range(50):
  # while f_input.next():
    f_input.next()
    e = f_input.entry
    seq_len = len(e.sequence)
    seq_lens.append(seq_len)
    # print seq_len
  print sorted(set(seq_lens))

    

start_dir = sys.argv[1]
print "Start from %s" % start_dir
print "Getting file names"

all_dirs = set()

#fq_files = get_files("/xraid2-2/sequencing/Illumina", ".fastq.gz")
# "/xraid2-2/sequencing/Illumina/20151014ns"
fq_files = get_files(start_dir, "1_R1.fastq.gz")
print "Found %s 1_R1.fastq.gz files" % (len(fq_files))

check_if_verb = check_if_verb()

for file_name in fq_files:
  if (check_if_verb):
    print file_name

  try:
    f_input  = fq.FastQSource(file_name, compress)
    compare_w_score(f_input, file_name, all_dirs)
    get_seq_len(f_input, file_name, all_dirs)
  except RuntimeError:
    if (check_if_verb):
      print sys.exc_info()[0]
  except:
    print "Unexpected error:", sys.exc_info()[0]
    next

print all_dirs


