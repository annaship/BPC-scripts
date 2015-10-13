import MySQLdb
import sys
import os
import shutil
import shared #use shared to call connection from outside of the module
from pprint import pprint
# from os import listdir
# from os.path import isfile, join


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
          # print "=" * 40
          # print "host = " + str(host) + ", db = "  + str(db)
          # print "=" * 40

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

class Index_Numbers_fromDB():
    # get idx_numbers from db: get_idx_numbers()
    # get current names: get_all_current_names()
    # create dict: make_self.names_dict()
    # if domain and dna_region is correct
    ## make_new_names:
    ### create a new name using a number from the current name
    ### rename
    
    def __init__(self, domain, dna_region):
      
        if len(dna_region) > 0 and len(domain) > 0:
          self.dna_region  = dna_region
          self.domain      = domain
          self.mypath      = "."

          self.domains     = self.get_domain_from_db()
          self.dna_regions = self.get_dna_region_from_db()
        
          if self.check_domain_name() and self.check_dna_region_name():
            self.res_names_dict = dict(self.get_idx_numbers())
            self.onlyfiles      = self.get_all_current_names()      
            self.make_new_names()
            print "Renamed"
          else:
            print """Not renamed, please check command line arguments:
          
            Possible domains: %s

            Possible dna regions: %s
            """ % (', '.join([str(i[0]) for i in self.domains]), ', '.join([str(i[0]) for i in self.dna_regions]))
        
      
    def get_all_current_names(self):
      onlyfiles = [ f for f in os.listdir(self.mypath) if os.path.isfile(os.path.join(self.mypath,f)) ]
      # onlyfiles = [ f for f in os.listdir(self.mypath) if (os.path.isfile(os.path.join(self.mypath,f)) and f.startswith("IDX")) ]
      return onlyfiles
    
    def change_to_lead_zero(self, idx_num):
      if len(idx_num) == 1:
        return ("0" + idx_num)
      else: 
        return idx_num
    
    def get_idx_num(self, file_name):
      idx_num = file_name.split("_")[0][3:]
      idx_num = self.change_to_lead_zero(idx_num)
      return idx_num

    def change_name_to_index(self, file_name):
      idx_num = self.get_idx_num(file_name)      
      new_name = self.res_names_dict[idx_num] + "_" + file_name
      return new_name
        
    def run_query(self, my_query):
      shared.my_conn.cursor.execute (my_query)
      result = shared.my_conn.cursor.fetchall ()      
      return result
      
    def get_idx_numbers(self):
        # print "domain = %s, dna_region = %s;" % (self.domain, self.dna_region)
        query_sel_name = """SELECT REPLACE(illumina_adaptor, \"A\", \"\") AS IDX_number, illumina_index 
                             FROM illumina_adaptor_ref 
                             JOIN illumina_adaptor using(illumina_adaptor_id) 
                             JOIN illumina_index using(illumina_index_id)
                             JOIN illumina_run_key using(illumina_run_key_id)
                             JOIN dna_region using(dna_region_id)
                          	 WHERE domain = \"%s\"
                          	 	AND  dna_region = \"%s\"
                          	 	AND illumina_adaptor like \"A%%\"
            """ % (self.domain, self.dna_region)

        res_names = self.run_query(query_sel_name)
        return res_names
        
    def make_new_names(self):
        for file_name in self.onlyfiles:
          if file_name.startswith("IDX"):
            new_name = self.change_name_to_index(file_name)            
            try:
              os.rename(file_name, new_name)
            except:
              raise
              
    def get_domain_from_db(self):
      my_query = """SELECT DISTINCT domain
           FROM illumina_adaptor_ref 
           JOIN illumina_adaptor using(illumina_adaptor_id) 
           JOIN illumina_index using(illumina_index_id)
           JOIN illumina_run_key using(illumina_run_key_id)
           JOIN dna_region using(dna_region_id)
      """
      return self.run_query(my_query)
      
    def get_dna_region_from_db(self):
      my_query = """SELECT DISTINCT dna_region
           FROM illumina_adaptor_ref 
           JOIN illumina_adaptor using(illumina_adaptor_id) 
           JOIN illumina_index using(illumina_index_id)
           JOIN illumina_run_key using(illumina_run_key_id)
           JOIN dna_region using(dna_region_id)
      """
      return self.run_query(my_query)

    def check_domain_name(self):
      if any(self.domain in domain for domain in self.domains):
        return True
      else:
        return False
      
    def check_dna_region_name(self):
      if any(self.dna_region in dna_region for dna_region in self.dna_regions):
        return True
      else:
        return False

