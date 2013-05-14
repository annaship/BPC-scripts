import MySQLdb
import sys
import shared #use shared to call connection from outside of the module
from pprint import pprint

class MyConnection:
  """
  Connection to env454
  Takes parameters from ~/.my.cnf, default host = "vampsdev", db="test"
  if different use my_conn = MyConnection(host, db)
  """
  def __init__(self, host="vampsdev", db="test"):
      self.conn   = None
      self.cursor = None
      self.rows   = 0
      self.new_id = None
      self.lastrowid = None
              
      try:
          print "=" * 40
          print "host = " + str(host) + ", db = "  + str(db)
          print "=" * 40

          self.conn   = MySQLdb.connect(host=host, db=db, read_default_file="~/.my.cnf")
          self.cursor = self.conn.cursor()
                 
      except MySQLdb.Error, e:
          print "Error %d: %s" % (e.args[0], e.args[1])
          raise
      except:                       # catch everything
          print "Unexpected:"         # handle unexpected exceptions
          print sys.exc_info()[0]     # info about curr exception (type,value,traceback)
          raise                       # re-throw caught exception   

  def close(self):
    if self.cursor:
      # print dir(self.cursor)
      self.cursor.close()
      self.conn.close()
      
  def execute_fetch_select(self, sql):
      if self.cursor:
          self.cursor.execute(sql)
          res = self.cursor.fetchall ()
          return res

  def execute_no_fetch(self, sql):
      if self.cursor:
          self.cursor.execute(sql)
          self.conn.commit()
          return self.cursor.lastrowid

class MySQLUtil:
    def __init__(self):
        pass
        
    def rename_files_to_dataset(self):
        pass        
        # get idx_runkey - project/dataset info from db: get_file_prefix_project_dataset()
        # create dict: make_names_dict()
        # take all file names in the dir from args
        # cp! and rename files
        
    def make_names_dict(self):
        res_names  = self.get_file_prefix_project_dataset()
        sequences   = (('AFP_POW_Bv6', 'PW18_Station3_150meters', 1, 'ACAGTG_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW24_Station1_85meters', 1, 'ACTTGA_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW13_Station8_surface', 1, 'ATCACG_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW21_Station8_100meters', 1, 'CAGATC_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW14_Station10_100meters', 1, 'CGATGT_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW28_Station6_145meters', 1, 'GATCAG_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW20_Station7_90meters', 1, 'GCCAAT_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW16_Station2_surface', 1, 'TGACCA_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW15_Station6_Surface', 1, 'TTAGGC_NNNNACGCA_1'), ('AFP_POW_Bv6', 'PW5_Station4_160meters', 1, 'ACAGTG_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW8_Station9_surface', 1, 'ACTTGA_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW7_Station9_110meters', 1, 'CAGATC_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW1_Station5_surface', 1, 'CGATGT_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW12_Station3_surface', 1, 'CTTGTA_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW9_Station10_surface', 1, 'GATCAG_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW6_Station7_surface', 1, 'GCCAAT_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW11_Station1_Mic_85meters', 1, 'GGCTAC_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW10_Station4_surface', 1, 'TAGCTT_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW3_Station5_135meters', 1, 'TGACCA_NNNNGCTAC_1'), ('AFP_POW_Bv6', 'PW2_Station2_110meters', 1, 'TTAGGC_NNNNGCTAC_1'), ('AFP_ASPIR_Bv6', 'Ant17_Polynya_deep', 1, 'ACAGTG_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant20_Polynya_Surface', 1, 'ACTTGA_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant13_Polynya_Surface', 1, 'ATCACG_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant19_Polynya_Surface', 1, 'CAGATC_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant14_Polynya_Surface', 1, 'CGATGT_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant21_Polynya_Surface', 1, 'GATCAG_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant18_Polynya_Surface', 1, 'GCCAAT_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant23_Dotson_ice_shelf_mix', 1, 'GGCTAC_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant22_Polynya_Surface', 1, 'TAGCTT_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant16_Polynya_deep', 1, 'TGACCA_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant15_Polynya_Surface', 1, 'TTAGGC_NNNNGTATC_1'), ('AFP_ASPIR_Bv6', 'Ant5_Polynya_Surface', 1, 'ACAGTG_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant8_Polynya_Surface', 1, 'ACTTGA_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant1_Shelf_Break_Surface', 1, 'ATCACG_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant7_Dotson_ice_shelf_mix', 1, 'CAGATC_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant2_Shelf_Break_deep', 1, 'CGATGT_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant12_Polynya_Surface', 1, 'CTTGTA_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant9_Polynya_Surface', 1, 'GATCAG_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant6_Dotson_ice_shelf_Surface', 1, 'GCCAAT_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant11_Polynya_Surface', 1, 'GGCTAC_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant10_Shelf_Break_Surface', 1, 'TAGCTT_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant4_Dotson_ice_shelf_deep', 1, 'TGACCA_NNNNTCAGC_1'), ('AFP_ASPIR_Bv6', 'Ant3_Shelf_Break_deep', 1, 'TTAGGC_NNNNTCAGC_1'), ('JAH_MCR_Av6', 'FS851_3', 1, 'GCGGTA_NNNNTAGCA_1'))
        
        names_dict = {}
        for sequence in sequences:            
            names_dict[sequence[3]] = sequence[0] + "-" + sequence[1]
            # names_dict = dict((key, value) for (sequence[3], sequence[0] + "_" + sequence[1]) in sequence)
        print names_dict
            # [(x, "output" + x[7:-4].zfill(4) + ".png") for x in os.listdir(path) if x.startswith("output_") and x.endswith(".png")]
        
        
    def get_file_prefix_project_dataset(self):
        # todo: run and lane in arguments
        query_sel_name = """SELECT DISTINCT project, dataset, lane, file_prefix 
			FROM env454.run_info_ill 
			JOIN env454.run USING(run_id) 
			JOIN env454.project USING(project_id) 
			JOIN env454.dataset USING(dataset_id) 
			WHERE run = \"20130322\" AND lane = 1 
            """
        print query_sel_name
        shared.my_conn.cursor.execute (query_sel_name)
        res_names = shared.my_conn.cursor.fetchall ()
        return res_names
        

