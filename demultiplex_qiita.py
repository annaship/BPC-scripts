import sys, getopt
import IlluminaUtils.lib.fastalib as fastalib

class Demultiplex:

  def __init__(self):
    self.out_files = []
    self.inputfile  = ''


  def usage(self):
    print '''python demultiplex_qiita.py -i <inputfile>
             '''

  def get_args(self, argv):
  
      try:
        opts, args = getopt.getopt(argv, "hi:", ["ifile="])
        # print "opts = %s, args = %s" % (opts, args)
      except getopt.GetoptError:
        sys.exit(2)
      
      for opt, arg in opts:
        if opt == '-h':
          usage()
          sys.exit()
        elif opt in ("-i", "--ifile"):
          self.inputfile = arg
              
      # print "min_refhvr_cut_len = %s" % min_refhvr_cut_len
      return (self.inputfile)
      
  def demultiplex_input(self, inputfile):
    
    #    input  = u.FastQSource('/path/to/file.fastq')
    #    output = u.FastQOutput('/path/to/output.fastq')
    #
    #    while input.next(trim_from = 5, trim_to = 75):
    #        if input.entry.Q_mean > 20:
    #            output.store_entry(input.entry)
    
    f_input  = fastalib.SequenceSource(inputfile)
    sample_name = "test"
    f_output = fastalib.FastaOutput(sample_name)
    
    while f_input.next():
        id = f_input.id
        # self.out_files[id]
        f_output.store(f_input)
  
    # for f_name in file_name_base:
    #     output_file = os.path.join(self.out_file_path, f_name + ".fastq")
    #     self.out_files[f_name] = fq.FastQOutput(output_file)
    # self.out_files["unknown"] = fq.FastQOutput(os.path.join(self.out_file_path, "unknown" + ".fastq"))
    # f_input  = fastalib.SequenceSource(inputfile)
    # self.fasta = SequenceSource(f_name)
    #
    # while self.fasta.next():
    #     if self.fasta.pos % 1000 == 0 or self.fasta.pos == 1:
    #         sys.stderr.write('\r[fastalib] Reading FASTA into memory: %s' % (self.fasta.pos))
    #         sys.stderr.flush()
    #     self.ids.append(self.fasta.id)
    #     self.sequences.append(self.fasta.seq)
    #
    # while f_input.next():
    #     id = f_input.id
    #     self.out_files[id].store_entry(e)


      

  """
  
  def make_file_names(self, headlines_dict):
    return [headline.split("_")[0] + ".fa" for headline in headlines_dict]
  

  def open_out_sample_files(self,inputfile_content_ids):
      sample_names = make_file_names(inputfile_content_ids)
      for sample in sample_names:
          self.out_files[sample] = fastalib.FastaOutput(sample)
      return sample_names

  def close_sample_files(self,out_files):
      [o_file[1].close() for o_file in out_files.items()] 
      return

  def demultiplexing(self):
    for sample in self.sample_names:
        self.out_files[sample] = fastalib.FastaOutput(sample)
    self.out_files[f_name] = fastalib.FastaOutput(output_file)
    f_input  = fq.FastQSource(file_r1, compressed)
    index_sequence = self.get_index(file_r1)
    while f_input.next():
        e = f_input.entry
        self.out_files["unknown"].store_entry(e)
  ---
  def open_out_sample_files(inputfile_content_ids):
      sample_names = make_file_names(inputfile_content_ids)
      out_files = {}
      for sample in sample_names:
        out_files[sample] = open(sample, "a")
      # out_files = dict([(sample, fastalib.FastaOutput(sample)) for sample in sample_names])
      return out_files


  def write_id(opened_file, id):
      opened_file.write('>%s\n' % id)

  def write_seq(opened_file, seq):
      opened_file.write('%s\n' % seq)
  """
  """ 
  def open_dataset_files(self):
      file_name_base = [i + "_R1" for i in self.runobj.samples.keys()] + [i + "_R2" for i in self.runobj.samples.keys()]
      for f_name in file_name_base:
          output_file = os.path.join(self.out_file_path, f_name + ".fastq")
          self.out_files[f_name] = fq.FastQOutput(output_file)
      self.out_files["unknown"] = fq.FastQOutput(os.path.join(self.out_file_path, "unknown" + ".fastq"))        

              f_input  = fq.FastQSource(file_r1, compressed)
              index_sequence = self.get_index(file_r1)
              while f_input.next():
                  e = f_input.entry
                  # todo: a fork with or without NNNN, add an argument
                  #                 ini_run_key  = index_sequence + "_" + "NNNN" + e.sequence[4:9] + "_" + e.lane_number   
                  has_ns = any("NNNN" in s for s in self.runobj.run_keys)           
  #                 has_ns = True             
                  ini_run_key  = index_sequence + "_" + self.get_run_key(e.sequence, has_ns) + "_" + e.lane_number 
                  if int(e.pair_no) == 1:
                      dataset_file_name_base_r1 = ini_run_key + "_R1"
                      if (dataset_file_name_base_r1 in self.out_files.keys()):
                          self.out_files[dataset_file_name_base_r1].store_entry(e)
                          "TODO: make a method:"
                          short_id1 = e.header_line.split()[0]
                          short_id2 = ":".join(e.header_line.split()[1].split(":")[1:])
                          id2 = short_id1 + " 2:" + short_id2
                          self.id_dataset_idx[id2] = ini_run_key
                  else:
                      self.out_files["unknown"].store_entry(e)
                    
  def read2(self, files_r2, compressed):
      "3) e.pair_no = 2, find id from 2), assign dataset_name"
      for file_r2 in files_r2:
          self.utils.print_both("FFF2: file %s" % file_r2)
          f_input  = fq.FastQSource(file_r2, compressed)
          while f_input.next():
              e = f_input.entry
            
  #                 start = time.time()  
  #                 time_before = self.utils.get_time_now()
  #                 e.sequence = self.remove_end_ns_strip(e.sequence)
  #                 elapsed = (time.time() - start)
  #                 print "remove_end_ns_strip with strip is done in: %s" % (elapsed)      
            
              if (int(e.pair_no) == 2) and (e.header_line in self.id_dataset_idx):
                  file_name = self.id_dataset_idx[e.header_line] + "_R2"
                  self.out_files[file_name].store_entry(e)        
              else:
                  self.out_files["unknown"].store_entry(e)
  """
if __name__ == "__main__":
    
    demult = Demultiplex()

    (inputfile) = demult.get_args(sys.argv[1:])
    print 'Input file is "%s"' % inputfile
    
    demult.demultiplex_input(inputfile)
    

    # inputfile_content = fastalib.ReadFasta(inputfile)
    #
    # out_files = open_out_sample_files(inputfile_content.ids)
    #
    # fa_dictionary = dict(zip(inputfile_content.ids, inputfile_content.sequences))
    #
    # for id, seq in fa_dictionary.items():
    #   file_name = id.split("_")[0] + ".fa"
    #   write_id(out_files[file_name], id)
    #   write_seq(out_files[file_name], seq)
    #
    # close_sample_files(out_files)
    
    