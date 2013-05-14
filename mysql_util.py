import MySQLdb
import sys
import os
import shutil
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
    
    def split_old_file_name(self, filename, dict_name):
         # name_split = filename.split(".")
         # print "filename = %s, name_split[1:] = %s" % (filename, name_split)
         # basename, extentions = name_split[0], ".".join(name_split[1:])
         # print "basename = %s, extentions = %s" % (basename, extentions)
         # [os.rename(f, f.replace('_', '-')) for f in os.listdir('.') if not f.startswith('.')]
         # [print f_name.replace(dict_name) for ]
         pass
         
         
    
    def get_file_names(self, path = "."):
        path       = '/users/ashipunova/test_del'
        names_dict = self.make_names_dict()
        # print names_dict.keys()
        for filename in os.listdir(path):            
            for dict_name in names_dict.keys():
                # print "filename = %s, dict_name = %s" % (filename, dict_name)
                
                if filename.startswith(dict_name):
                    # [print f_name.replace(dict_name, names_dict[dict_name]) for f_name in ]
                    old_name = filename                    
                    new_name = filename.replace(dict_name, names_dict[dict_name])
                    
                    # old_basename, old_extentions = 
                    # self.split_old_file_name(filename, dict_name)
                    # old_name = filename
                    # new_name = names_dict[dict_name]
                    print "old_name = %s,\t\t\t\t\t new_name = %s" % (old_name, new_name)
                    shutil.copyfile(os.path.join(path, old_name), os.path.join(path, new_name))
        
        # file_names = 
        # l = [(x, "output" + x[7:-4].zfill(4) + ".png") for x in os.listdir(path) if x.startswith("output_") and x.endswith(".png")]
        
        
    def make_names_dict(self):
        res_names  = self.get_file_prefix_project_dataset()
        names_dict = dict([(names[3], names[0] + "-" + names[1]) for names in res_names])
        return names_dict
        
    def get_file_prefix_project_dataset(self):
        # todo: run and lane in arguments
        query_sel_name = """SELECT DISTINCT project, dataset, lane, file_prefix 
			FROM env454.run_info_ill 
			JOIN env454.run USING(run_id) 
			JOIN env454.project USING(project_id) 
			JOIN env454.dataset USING(dataset_id) 
			WHERE run = \"20130419\" AND lane = 1 
            """
        print query_sel_name
        shared.my_conn.cursor.execute (query_sel_name)
        res_names = shared.my_conn.cursor.fetchall ()
        return res_names
        

