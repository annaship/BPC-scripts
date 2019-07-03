import os
import sys
import gzip
from itertools import islice


class Utils:
  def __init__(self, args):
    self.verbatim = args.verbatim

  def check_if_verb(self):
    try:
      if self.verbatim:
        return True
    except IndexError:
      return False

    return False

  def print_output(self, one_fastq, output):
    print(one_fastq[0].decode('utf-8').strip(), file=output)
    print(one_fastq[1].decode('utf-8').strip(), file=output)
    print(one_fastq[2].decode('utf-8').strip(), file=output)
    print(one_fastq[3].decode('utf-8').strip(), file=output)


class Files:
    def __init__(self, args):
      self.start_dir  = self.get_start_dir(args)
      self.compressed = args.compressed
      if args.ext is None and self.compressed is True:
          self.ext    = "1_R1.fastq.gz"
      elif args.ext is not None:
          self.ext    = args.ext
      else:
          self.ext    = "1_R1.fastq"
      print("extension = %s" % self.ext)

    def get_start_dir(self, args):
      if not os.path.exists(args.start_dir):
          print("Input fastq file with the '%s' extension does not exist in %s" % (self.ext, self.start_dir))
          sys.exit()
      print("Start from %s" % args.start_dir)
      return args.start_dir

    def get_dirs(self, fq_files):
      # all_dirs = set()
      # all_dirs.add(fq_files[file_name][0])
      return [file_name[0] for file_name in fq_files]

    def get_fq_files_info(self):
      # fq_files = get_files("/xraid2-2/sequencing/Illumina", ".fastq.gz")
      # "/xraid2-2/sequencing/Illumina/20151014ns"
      print("Getting file names")
      fq_files = self.get_files()
      print("Found %s %s" % (len(fq_files), self.ext))
      return fq_files

    def get_files(self):
        files = {}

        for dirname, dirnames, filenames in os.walk(self.start_dir, followlinks=True):
            if self.ext:
                filenames = [f for f in filenames if f.endswith(self.ext)]

            for file_name in filenames:
                full_name = os.path.join(dirname, file_name)
                (file_base, file_extension) = os.path.splitext(os.path.join(dirname, file_name))
                files[full_name] = (dirname, file_base, file_extension)
        return files

    def get_output_file_pointer(self, file_name, compressed = False):
      output_file_name = file_name + '_adapters_trimmed.fastq'
      if compressed:
          output_file_name = output_file_name + ".gz"
          output_file_p = gzip.open(output_file_name, 'at')
      else:
          output_file_p = open(output_file_name, 'a')
      return output_file_p
      
    def get_input_file_pointer(self, file_name, compressed = False, mode = 'r'):
        if compressed:
            return gzip.open(file_name, mode)
        else:
            return open(file_name, mode)


class Reads:
    def __init__(self, args):
        self.quality_len = args.quality_len
    
    def get_adapter(self, file_name):
      file_name_arr = file_name.split("_")
      try:
        adapter = file_name_arr[1]
        if any(ch not in 'ACGTN' for ch in adapter):
          print("File name should have INDEX_ADAPTER at the beginning. This file name (%s) is not valid for removing adapters" % file_name)
          sys.exit()
      except IndexError:
        print("File name should have INDEX_ADAPTER at the beginning. This file name (%s) is not valid for removing adapters" % file_name)
        sys.exit()
      return adapter

    def go_over_input(self, file_name, compressed):
      with files.get_input_file_pointer(file_name, compressed) as f:
        output_file_p  = files.get_output_file_pointer(file_name, compressed)
        
        n = 4
        while True:
          next_n_lines = list(islice(f, n))
          if not next_n_lines:
            break
          one_fastq_removed_adapters = self.remove_adapters(next_n_lines, file_name)
          utils.print_output(one_fastq_removed_adapters, output_file_p)
        output_file_p.close()
      
    def remove_adapters(self, one_fastq, file_name):

      adapter = reads.get_adapter(file_name)
      adapter_len = len(adapter)
      seq_no_adapter = one_fastq[1][adapter_len:]
      qual_scores_short = one_fastq[3][adapter_len:]

      one_fastq[1] = seq_no_adapter
      one_fastq[3] = qual_scores_short
      
      return one_fastq

    def remove_adapters_n_primers(self, one_fastq, file_name):

        adapter = reads.get_adapter(file_name)
        adapter_len = len(adapter)
        seq_no_adapter = one_fastq[1][adapter_len:]
        qual_scores_short = one_fastq[3][adapter_len:]

        one_fastq[1] = seq_no_adapter
        one_fastq[3] = qual_scores_short

        return one_fastq

    # def remove_adapters_n_primers(self, f_input, file_name):
    #   output_file_name = file_name + '_adapters_n_primers_trimmed.fastq'
    #   output = open(output_file_name, 'a')
    #   B_forward_primer_re = "^CCAGCAGC[CT]GCGGTAA."
    #
    #   while f_input.next():
    #     f_input.next(raw = True)
    #     e = f_input.entry
    #     adapter = self.get_adapter(file_name)
    #     # print(adapter)
    #
    #     adapter_len = len(adapter)
    #     seq_no_adapter = e.sequence[adapter_len:]
    #     print("seq_no_adapter:")
    #     print(seq_no_adapter)
    #
    #     m = re.search(B_forward_primer_re, seq_no_adapter)
    #     forward_primer = m.group(0)
    #     print("forward_primer:")
    #     print(forward_primer)
    #
    #     primer_len = len(forward_primer)
    #
    #
    #     # m.group(0):
    #     # CCAGCAGCTGCGGTAAC
    #     seq_no_primer = seq_no_adapter[primer_len:]
    #     print("seq_no_primer:")
    #     print(seq_no_primer)
    #
    #     e.sequence = seq_no_primer
    #     # print("e.sequence:")
    #     # print(e.sequence)
    #
    #     output.store_entry(e)
    #
    #     # TODO: fix
    #     # TODO cut other lines (score etc.)
    #     # print("adapter_len = ")
    #     # print(adapter_len)
    #     # print(e.sequence)
    #     # print("seq_no_adapter:")
    #     # print(seq_no_adapter)
    #     # print("---")
    #

    def compare_w_score(self, f_input, file_name, all_dirs):
      for _ in range(50):
        f_input.next(raw = True)
        e = f_input.entry

        print(e)

        seq_len = len(e.sequence)
        qual_scores_len = len(e.qual_scores)
        try:
            if self.quality_len:
                print("\n=======\nCOMPARE_W_SCORE")
                print("seq_len = %s" % seq_len)
                print("qual_scores_len = %s" % qual_scores_len)
        except IndexError:
            pass

        if seq_len != qual_scores_len:
          print("WARNING, sequence and qual_scores_line have different length in %s for %s" % (file_name, e.header_line))
          print("seq_len = %s" % seq_len)
          print("qual_scores_len = %s" % qual_scores_len)

          all_dirs.add(fq_files[file_name][0])

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='''Check fastq files reads and quality lines length.
    Command line example: python %(prog)s -d/--dir DIRNAME -e/--extension -v --compressed/-c
    ''')
    # todo: add user_config
    # parser.add_argument('--user_config', metavar = 'CONFIG_FILE',
    #                                     help = 'User configuration to run')
    parser.add_argument('--dir', '-d', required = True, action='store', dest='start_dir',
                        help = 'A start directory path.')
    parser.add_argument('--extension', '-e', required = False, action='store', dest='ext',
                        help = 'An extension to look for. Default is a "1_R1.fastq".')
    parser.add_argument('--compressed', '-c', action = "store_true", default = False,
                        help = 'Use if fastq compressed. Default is a %(default)s.')
    parser.add_argument('--quality_len', '-q', action = "store_true", default = False,
                        help = 'Print out the quality and read length. Default is a %(default)s.')
    parser.add_argument('--verbatim', '-v', action = "store_true", default = False,
                        help = 'Print outs.')

    args = parser.parse_args()
    print(args)

    files = Files(args)
    reads = Reads(args)
    utils = Utils(args)
    check_if_verb = utils.check_if_verb()

    fq_files = files.get_fq_files_info()
    all_dirs = files.get_dirs(fq_files)

    for file_name in fq_files:
      compressed = args.compressed
      reads.go_over_input(file_name, compressed)

      # if compressed:
      #     input_file_p = gzip.open(file_name, 'r')
      # else:
      #     input_file_p = open(file_name, 'r')
      #
      # output = files.get_output_file_pointer(file_name)
      #
      # cnt = 0
      # content = []
      # one_fastq_dict = {}
      # while 1:
      #   cnt += 1
      #   if cnt == 5:
      #     cnt = 1
      #
      #   line = file.readline().strip()
      #   one_fastq_dict = reads.get_one_fastq_dict(line, cnt)
      #   if cnt == 4:
      #     content.append(one_fastq_dict)
      #
      #     adapter = reads.get_adapter(file_name)
      #     adapter_len = len(adapter)
      #     seq_no_adapter = one_fastq_dict["sequence"][adapter_len:]
      #     qual_scores_short = one_fastq_dict["qual_scores"][adapter_len:]
      #
      #     one_fastq_dict["sequence"] = seq_no_adapter
      #     one_fastq_dict["qual_scores"] = qual_scores_short
      #
      #     utils.print_output(one_fastq_dict, output)
      #
      #   if not line:
      #     break
      # output.close()
      # file.close()

    print("Directories: %s" % set(all_dirs))
