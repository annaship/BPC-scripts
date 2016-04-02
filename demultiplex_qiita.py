import sys, getopt
import IlluminaUtils.lib.fastalib as fastalib

class Demultiplex:

  def __init__(self):
    self.ids        = set()
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
      
      
  def write_id(self, output_file_obj, id):
      output_file_obj.write('>%s\n' % id)

  def write_seq(self, output_file_obj, seq):
      # if split:
      #     seq = fastalib.FastaOutput.split(seq)
      output_file_obj.write('%s\n' % seq)

  def demultiplex_input(self, inputfile):
    
    f_input  = fastalib.SequenceSource(inputfile)
    
    while f_input.next():
      id = f_input.id
      
      f_out_name = id.split("_")[0] + ".fa"
      self.ids.add(f_out_name)
      
      print "f_out_name = %s" % f_out_name
      f_output = open(f_out_name, 'a')
      self.write_id(f_output, id)
      self.write_seq(f_output, f_input.seq)
      f_output.close()
        
    # print self.ids
    
  def close_sample_files(self):
    [o_file[1].close() for o_file in self.ids] 
    return    
        

if __name__ == "__main__":
    
    demult = Demultiplex()

    (inputfile) = demult.get_args(sys.argv[1:])
    print 'Input file is "%s"' % inputfile
    
    demult.demultiplex_input(inputfile)
    
    # demult.close_sample_files()
    
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
    
    