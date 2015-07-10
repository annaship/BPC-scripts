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

class Index_Numbers_fromDB():
    # get idx_numbers from db: get_idx_numbers()
    # create dict: make_self.names_dict()
    # take all file names in the dir from args
    # cp! and rename files
    # remove new files
    
    def __init__(self, domain, dna_region):
        self.dna_region = dna_region
        self.domain     = domain

        self.res_names_dict = dict(self.get_idx_numbers())
        # print self.res_names_dict

        self.mypath = "."
        self.onlyfiles  = self.get_all_current_names()
        print self.onlyfiles
        
        self.make_new_names()
        # self.names_dict = self.make_names_dict(res_names)
      
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
      print  "FFF file_name = %s" % file_name
      idx_num = file_name.split("_")[0][3:]
      # print "idx_num = %s" % idx_num
      idx_num = self.change_to_lead_zero(idx_num)
      # print "III idx_num = %s" % idx_num
      return idx_num

    def change_name_to_index(self, file_name):
      idx_num = self.get_idx_num(file_name)
      print "DDD idx_num = %s" % idx_num
      print self.res_names_dict[idx_num]
      
      new_name = self.res_names_dict[idx_num] + "_" + file_name
      return new_name
      
    def make_new_names(self):
        for file_name in self.onlyfiles:
          if file_name.startswith("IDX"):
            new_name = self.change_name_to_index(file_name)
            print "NNN new_name = %s\n++++" % new_name
            
            try:
              os.rename(file_name, new_name)
            except:
              raise
        
    # def remove_all_new_files(self, path = "."):
    #     for filename in os.listdir(path):
    #         for new_filename in self.names_dict.values():
    #             if filename.startswith(new_filename):
    #                 try:
    #                     os.remove(filename)
    #                 except OSError:
    #                     pass
    #
    def rename_files_to_index(self):
      pass
        # for filename in os.listdir(path):
        #     # works, but slower!:
        #     # [shutil.copyfile(os.path.join(path, filename), os.path.join(path, filename.replace(dict_name, self.names_dict[dict_name]))) for dict_name in self.names_dict.keys() if filename.startswith(dict_name)]
        #     for dict_name in self.names_dict.keys():
        #         if filename.startswith(dict_name):
        #             new_name = filename.replace(dict_name, self.names_dict[dict_name])
        #             print "Copying %s to %s" % (filename, new_name)
        #             shutil.copyfile(os.path.join(path, filename), os.path.join(path, new_name))
        
    # def make_names_dict(self, res_names):
    #     self.names_dict = dict([(names[3], names[0] + "-" + names[1]) for names in res_names])
    #     return self.names_dict
        
    def get_idx_numbers(self):
        print "domain = %s, dna_region = %s;" % (self.domain, self.dna_region)
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
        print query_sel_name
        shared.my_conn.cursor.execute (query_sel_name)
        res_names = shared.my_conn.cursor.fetchall ()
        print res_names
        return res_names
        

