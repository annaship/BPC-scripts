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
          print("=" * 40)
          print("host = " + str(host) + ", db = "  + str(db))
          print("=" * 40)

          self.conn   = MySQLdb.connect(host=host, db=db, read_default_file="~/.my.cnf")
          self.cursor = self.conn.cursor()
                 
      except MySQLdb.Error, e:
          print("Error %d: %s" % (e.args[0], e.args[1]))
          raise
      except:                       # catch everything
          print("Unexpected:")        # handle unexpected exceptions
          print(sys.exc_info()[0])     # info about curr exception (type,value,traceback)
          raise                       # re-throw caught exception   

  def close(self):
    if self.cursor:
      # print(dir(self.cursor))
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

class SqlUtil:
    def __init__(self):
        pass
        
    # compare with previous:
    def compare_res_w_previous(self, table_list = ["vamps_data_cube", "vamps_junk_data_cube", "vamps_projects_datasets", "vamps_sequences", "vamps_taxonomy"]):
      # print(type(table_list))
      for table_name in table_list:
        res1 = ""
        res_previous = ""
        shared.my_conn.cursor.execute ("""
        select count(*) from %s """ %
        (table_name)
        )
        res1_f = shared.my_conn.cursor.fetchall ()
        previous_name = table_name+"_previous"
        shared.my_conn.cursor.execute ("""
        select count(*) from %s """ %
        (previous_name)
        )
        res_previous_f = shared.my_conn.cursor.fetchall ()
        res1 = str(res1_f[0][0])
        res_previous = str(res_previous_f[0][0])
        text0 = "\n\nprevious_name = "+previous_name+" size = "+res_previous+"; table_name = "+table_name+" size = " + res1
        print(text0)
        t1 = int(res1) - int(res_previous)
        text01 = "(res1 - res_previous): current is bigger then previous for "+str(t1)
        if res1 < res_previous:
          text = "Please check vamps upload for this table, current is bigger then previous: "+previous_name+": "+res1+" < "+res_previous+"!"
          print(text)
        else:
          print("Hurray! "+table_name+": "+res_previous+" < "+res1)

    def compare_interm_w_current(self, table_list = ["vamps_data_cube", "vamps_junk_data_cube", "vamps_projects_datasets", "vamps_sequences", "vamps_taxonomy"]):
      # print(type(table_list))
      for table_name in table_list:
        res1 = ""
        res_intermediate = ""
        shared.my_conn.cursor.execute ("""
        select count(*) from %s """ %
        (table_name)
        )
        res1_f = shared.my_conn.cursor.fetchall ()
        intermediate_name = table_name+"_intermediate"
        shared.my_conn.cursor.execute ("""
        select count(*) from %s """ %
        (intermediate_name)
        )
        res_intermediate_f = shared.my_conn.cursor.fetchall ()
        res1 = str(res1_f[0][0])
        res_intermediate = str(res_intermediate_f[0][0])
        text0 = "\n\nintermediate_name = "+intermediate_name+" size = "+res_intermediate+"; table_name = "+table_name+" size = " + res1
        print(text0)
        t1 = int(res1) - int(res_intermediate)
        text01 = "(res1 - res_intermediate): current is bigger then intermediate for "+str(t1)
        if int(res1) > int(res_intermediate):
          text = "Please check vamps upload for this table, current is bigger then intermediate: "+intermediate_name+": "+res1+" > "+res_intermediate+"!"
          print(text)
        else:
          print("Hurray! "+table_name+": "+res_intermediate+" > "+res1)

    # from sql_tables_class import MyConnection
    # import sql_tables_client
    # sql_tables_client.compare_res_w_intermediate()
    # compare with intermediate:
    # def hmp_count_tax(self, ):
    #   shared.my_conn.cursor.execute ("""
    #     select distinct taxonomy from dawg_reads
    #   """)
    
    def create_junk_cube(self):
      ranks = ['superkingdom','phylum','class','`order`','family','genus','species','strain']
      ranks_subarray = [] # array for building the growing list of taxonomic ranks
      for i in range(0, len(ranks)):
        ranks_subarray.append(ranks[i])
        ranks_list = ", ".join(ranks_subarray); # i.e., superkingdom, phylum, class
        insertQuery = """INSERT IGNORE INTO hmp_vamps_junk_data_cube_pipe
          SELECT DISTINCT 0, concat_ws(';', %s) as taxonomy,
          sum(knt) as sum_tax_counts, sum(knt) / dataset_count AS frequency, dataset_count,
          %s AS rank, project, dataset, concat(project,'--',dataset), 'RDP'
          FROM hmp_vamps_data_cube_uploads
          WHERE taxon_string != ''
          GROUP BY project, dataset, %s
          HAVING length(taxonomy) - length(replace(taxonomy,';','')) >= %s""" % (ranks_list, i, ranks_list, i)
        shared.my_conn.cursor.execute(insertQuery)
        shared.my_conn.conn.commit()
        print(insertQuery)
    
    # previous (previous current)
    # current 
    # transfer (created by vamps upload from 454 or illumina)
    # intermediate (from transfer, to combine 454 and illumina before turn them to the current ones)    
    # norm: DROP TABLE IF EXISTS:
    # The order is important because of foreign keys
    # "new_user_contact_previous", "new_summed_data_cube_previous", "new_project_dataset_previous", "new_dataset_previous", "new_project_previous", "new_taxonomy_previous", "new_class_previous", "new_contact_previous", "new_family_previous", "new_genus_previous", "new_orderx_previous", "new_phylum_previous", "new_species_previous", "new_strain_previous", "new_superkingdom_previous", "new_taxon_string_previous", "new_user_previous"; 
    # my %norm_table_names =
    # ( "new_class", "new_contact", "new_dataset", "new_family", "new_genus", "new_orderx", "new_phylum", "new_project", "new_project_dataset", "new_species", "new_strain", "new_summed_data_cube", "new_superkingdom", "new_taxon_string", "new_taxonomy", "new_user", "new_user_contact"    # );
    def swap_vamps_tables(self, suffix_from, suffix_to, table_list = []):
      for table_name in table_list:
        
        from_table_name = table_name + suffix_from
        to_table_name   = table_name + suffix_to
        rename_query    = "RENAME TABLE %s TO %s" % (from_table_name, to_table_name);
        print(rename_query + "\n")
        try:
          shared.my_conn.cursor.execute (rename_query)
          shared.my_conn.conn.commit()
        except MySQLdb.OperationalError, e: 
            print(repr(e))
        except Exception, e: 
          print(repr(e))
          print("Unexpected:")         # handle unexpected exceptions
          print(sys.exc_info()[0])     # info about curr exception (type,value,traceback)
          raise

    def drop_tables(self, table_list = [], suffix = "_previous"):
      # print(type(table_list))
      # [shared.my_conn.cursor.execute ("DROP TABLE IF EXISTS %s" % (table_name + suffix)) for table_name in table_list]
      shared.my_conn.cursor.execute ("SET foreign_key_checks = 0;")
      shared.my_conn.conn.commit()
      for table_name in table_list:
        table_name_to_drop = table_name + suffix
        drop_query = "DROP TABLE IF EXISTS %s" % (table_name_to_drop)
        # print(drop_query)
        shared.my_conn.cursor.execute (drop_query)
        shared.my_conn.conn.commit()
      shared.my_conn.cursor.execute ("SET foreign_key_checks = 1;")
      shared.my_conn.conn.commit()

    def add_suffix(self, suffix, table_list):
      suff_table_names = {}
      suff_table_names = dict((table_name, table_name + suffix) for table_name in table_list)
      # print(suff_table_names['new_project'])
      # print(pprint(suff_table_names))
      return suff_table_names

    def update_intermediate_from_illumina_transfer(self, intermediate_names, transfer_names):      
      insert_vamps_data_cube_q         = """INSERT IGNORE INTO %s (project, dataset, taxon_string, superkingdom, phylum, class, `order`, family, genus, species, strain, rank, knt, frequency, dataset_count, classifier) SELECT project, dataset, taxon_string, superkingdom, phylum, class, `order`, family, genus, species, strain, rank, knt, frequency, dataset_count, classifier 
                                              FROM %s""" % (intermediate_names['vamps_data_cube'], transfer_names['vamps_data_cube'])
 #     insert_vamps_export_q            = """INSERT IGNORE INTO %s (read_id, project, dataset, refhvr_ids, distance, taxonomy, sequence, rank, date_trimmed) SELECT read_id, project, dataset, refhvr_ids, distance, taxonomy, sequence, rank, date_trimmed 
 #                                             FROM %s""" % (intermediate_names['vamps_export'], transfer_names['vamps_export'])
      insert_vamps_junk_data_cube_q    = """INSERT IGNORE INTO %s (taxon_string, knt, frequency, dataset_count, rank, project, dataset, project_dataset, classifier) SELECT taxon_string, knt, frequency, dataset_count, rank, project, dataset, project_dataset, classifier 
                                              FROM %s""" % (intermediate_names['vamps_junk_data_cube'], transfer_names['vamps_junk_data_cube'])
      insert_vamps_projects_datasets_q = """INSERT IGNORE INTO %s (project, dataset, dataset_count, has_sequence, date_trimmed, dataset_info) SELECT project, dataset, dataset_count, has_sequence, date_trimmed, dataset_info 
                                              FROM %s""" % (intermediate_names['vamps_projects_datasets'], transfer_names['vamps_projects_datasets'])
      insert_vamps_projects_info_q     = """INSERT IGNORE INTO %s (project_name, title, description, contact, email, institution, env_source_id, edits) SELECT project_name, title, description, contact, email, institution, env_source_id, edits 
                                              FROM %s""" % (intermediate_names['vamps_projects_info'], transfer_names['vamps_projects_info'])
      insert_vamps_sequences_q         = """INSERT IGNORE INTO %s (sequence, project, dataset, taxonomy, refhvr_ids, rank, seq_count, frequency, distance, rep_id, project_dataset) SELECT sequence, project, dataset, taxonomy, refhvr_ids, rank, seq_count, frequency, distance, rep_id, project_dataset 
                                              FROM %s""" % (intermediate_names['vamps_sequences'], transfer_names['vamps_sequences'])
      insert_vamps_taxonomy_q          = """INSERT IGNORE INTO %s (taxon_string, rank, num_kids) SELECT taxon_string, rank, num_kids 
                                              FROM %s""" % (intermediate_names['vamps_taxonomy'], transfer_names['vamps_taxonomy'])
      insert_new_superkingdom_q        = """INSERT IGNORE INTO %s (superkingdom) SELECT superkingdom 
                                              FROM %s""" % (intermediate_names['new_superkingdom'], transfer_names['new_superkingdom'])
      insert_new_phylum_q              = """INSERT IGNORE INTO %s (phylum) SELECT phylum 
                                              FROM %s""" % (intermediate_names['new_phylum'], transfer_names['new_phylum'])
      insert_new_class_q               = """INSERT IGNORE INTO %s (class) SELECT class FROM %s""" % (intermediate_names['new_class'], transfer_names['new_class'])
      insert_new_orderx_q              = """INSERT IGNORE INTO %s (`order`) SELECT `order` FROM %s""" % (intermediate_names['new_orderx'], transfer_names['new_orderx'])
      insert_new_family_q              = """INSERT IGNORE INTO %s (family) SELECT family FROM %s""" % (intermediate_names['new_family'], transfer_names['new_family'])
      insert_new_genus_q               = """INSERT IGNORE INTO %s (genus) SELECT genus FROM %s""" % (intermediate_names['new_genus'], transfer_names['new_genus'])
      insert_new_species_q             = """INSERT IGNORE INTO %s (species) SELECT species FROM %s""" % (intermediate_names['new_species'], transfer_names['new_species'])
      insert_new_strain_q              = """INSERT IGNORE INTO %s (strain) SELECT strain FROM %s""" % (intermediate_names['new_strain'], transfer_names['new_strain'])
      insert_new_taxon_string_q        = """INSERT IGNORE INTO %s (taxon_string, rank_number) SELECT taxon_string, rank_number FROM %s""" % (intermediate_names['new_taxon_string'], transfer_names['new_taxon_string'])
      insert_new_user_q                = """INSERT IGNORE INTO %s (user, passwd, active, security_level) SELECT user, passwd, active, security_level FROM %s""" % (intermediate_names['new_user'], transfer_names['new_user'])
      insert_new_contact_q             = """INSERT IGNORE INTO %s (first_name, last_name, email, institution, contact) SELECT first_name, last_name, email, institution, contact 
                                              FROM %s""" % (intermediate_names['new_contact'], transfer_names['new_contact'])
      insert_new_user_contact_q        = """INSERT IGNORE INTO %s (contact_id, user_id) 
        SELECT new_contact.contact_id, new_user.user_id
        FROM new_user_contact_ill
        join %s as new_user using(user)
        join %s as new_contact using(contact)
      """ % (intermediate_names['new_user_contact'], intermediate_names['new_user'], intermediate_names['new_contact'])
      
      # insert_new_project_q             = """INSERT IGNORE INTO %s (project, title, project_description, funding, env_sample_source_id, contact_id)
      #   SELECT project, title, project_description, funding, env_sample_source_id, contact_id
      #   FROM %s
      #   JOIN %s using(contact_id)
      #   """ % (intermediate_names['new_project'], transfer_names['new_project'], intermediate_names['new_contact'])
      
      insert_new_project_q             = """INSERT IGNORE INTO %s (project, title, project_description, funding, env_sample_source_id, contact_id) 
        SELECT project, title, project_description, funding, env_sample_source_id, new_contact_intermediate.contact_id  
        FROM %s
        JOIN %s using(contact_id)
        JOIN %s using(contact, email, institution)
        """ % (intermediate_names['new_project'], transfer_names['new_project'], transfer_names['new_contact'], intermediate_names['new_contact'])
        
# date
# Tue Sep 29 19:51:03 EDT 2015
        # SELECT project, title, project_description, funding, env_sample_source_id, new_contact_intermediate.contact_id
        #       FROM new_project_transfer
        #       JOIN new_contact_transfer USING(contact_id)
        #       JOIN new_contact_intermediate USING(contact, email, institution)
      
      insert_new_taxonomy_q            = """INSERT IGNORE INTO %s (taxon_string_id, superkingdom_id, phylum_id, class_id, orderx_id, family_id, genus_id, species_id, strain_id, rank_id, classifier) 
        SELECT new_taxon_string.taxon_string_id, new_superkingdom.superkingdom_id, new_phylum.phylum_id, new_class.class_id, new_orderx.orderx_id, new_family.family_id, 
          new_genus.genus_id, new_species.species_id, new_strain.strain_id, new_rank.rank_id, classifier
        FROM new_taxonomy_ill
          JOIN %s as new_taxon_string USING(taxon_string)
          JOIN %s as new_superkingdom USING(superkingdom)
          JOIN %s as new_phylum USING(phylum)
          JOIN %s as new_class USING(class)
          JOIN %s as new_orderx USING(`order`)
          JOIN %s as new_family USING(family)
          JOIN %s as new_genus USING(genus)
          JOIN %s as new_species USING(species)
          JOIN %s as new_strain USING(strain)
          JOIN %s as new_rank USING(rank)""" % (intermediate_names['new_taxonomy'], intermediate_names['new_taxon_string'], intermediate_names['new_superkingdom'], intermediate_names['new_phylum'], intermediate_names['new_class'], intermediate_names['new_orderx'], intermediate_names['new_family'], intermediate_names['new_genus'], intermediate_names['new_species'], intermediate_names['new_strain'], 'new_rank')
      insert_new_dataset_q             = """INSERT IGNORE INTO %s (dataset, dataset_description, reads_in_dataset, has_sequence, project_id, date_trimmed) 
        SELECT dataset, dataset_description, reads_in_dataset, has_sequence, new_project.project_id, date_trimmed 
        FROM new_dataset_ill
        join %s as new_project using(project)""" % (intermediate_names['new_dataset'], intermediate_names['new_project'])

      insert_new_project_dataset_q     = """INSERT IGNORE INTO %s (project_dataset, dataset_id, project_id) 
        SELECT project_dataset, new_dataset.dataset_id, new_project.project_id 
        FROM new_project_dataset_ill
          join %s as new_project using(project)
          join %s as new_dataset using(dataset)
          where new_dataset.project_id = new_project.project_id
          """ % (intermediate_names['new_project_dataset'], intermediate_names['new_project'], intermediate_names['new_dataset'])
      insert_new_summed_data_cube_q    = """INSERT IGNORE INTO %s (taxon_string_id, knt, frequency, dataset_count, rank_number, project_id, dataset_id, project_dataset_id, classifier) 
        SELECT new_taxon_string.taxon_string_id, knt, frequency, dataset_count, rank_number, new_project.project_id, new_dataset.dataset_id, new_project_dataset.project_dataset_id, classifier 
        FROM new_summed_data_cube_ill
          join %s as new_project using(project)
          join %s as new_dataset using(dataset)
          join %s as new_taxon_string using(taxon_string, rank_number)
          join %s as new_project_dataset using(project_dataset)
          where new_dataset.project_id = new_project.project_id
        """ % (intermediate_names['new_summed_data_cube'], intermediate_names['new_project'], intermediate_names['new_dataset'], intermediate_names['new_taxon_string'], intermediate_names['new_project_dataset'])

      query_names_exec = [ insert_vamps_data_cube_q, insert_vamps_junk_data_cube_q, insert_vamps_projects_datasets_q, insert_vamps_projects_info_q, insert_vamps_sequences_q, insert_vamps_taxonomy_q, insert_new_superkingdom_q, insert_new_phylum_q, insert_new_class_q, insert_new_orderx_q, insert_new_family_q, insert_new_genus_q, insert_new_species_q, insert_new_strain_q, insert_new_taxon_string_q, insert_new_user_q, insert_new_contact_q, insert_new_user_contact_q, insert_new_project_q, insert_new_taxonomy_q, insert_new_dataset_q, insert_new_project_dataset_q, insert_new_summed_data_cube_q ]
      # print("""SSS1: insert ill data\n""")
      for query_name in query_names_exec:
        print(query_name)
        shared.my_conn.cursor.execute(query_name)
        shared.my_conn.conn.commit()
        
      # print([(query_name + '\n') for query_name in query_names_exec])
      # [shared.my_conn.cursor.execute (query_name) in query_names_exec]
