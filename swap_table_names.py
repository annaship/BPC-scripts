import vamps_upload_util_class
import sys
import collections
import shared #use shared to call connection from outside of the module

from optparse import OptionParser

usage = """%s [454 | ill | rename | undo_rename ]. Vamps upload table names change, three steps.
454:         change 454 transfer to intermediate;
ill:         add illumina transfer to intermediate;
rename:      swap current to previous, then intermediate to current.
undo_rename: swap current to intermediate, then previous to current.
""" % (sys.argv[0])

if (sys.argv[1] == "help" or sys.argv[1] == "-h"):
    print usage

# shared.my_conn = vamps_upload_util_class.MyConnection(server_name = 'bpcdb2')
# shared.my_conn = vamps_upload_util_class.MyConnection(server_name = 'vampsdb')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdev', 'test')
# shared.my_conn = vamps_upload_util_class.MyConnection('newbpcdb2', 'env454')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb.mbl.edu', 'vamps')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdev', 'vamps2')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdev', 'vamps')

# previous (they were previous current ones)
# current 
# transfer (created by vamps upload from 454 or illumina)
# intermediate (from transfer, to combine 454 and illumina before turn them to the current ones)    
# norm: DROP TABLE IF EXISTS:
# The order is important because of foreign keys
# "new_user_contact_previous", "new_summed_data_cube_previous", "new_project_dataset_previous", "new_dataset_previous", "new_project_previous", "new_taxonomy_previous", "new_class_previous", "new_contact_previous", "new_family_previous", "new_genus_previous", "new_orderx_previous", "new_phylum_previous", "new_species_previous", "new_strain_previous", "new_superkingdom_previous", "new_taxon_string_previous", "new_user_previous"; 
# my %norm_table_names =
# ( "new_class", "new_contact", "new_dataset", "new_family", "new_genus", "new_orderx", "new_phylum", "new_project", "new_project_dataset", "new_species", "new_strain", "new_summed_data_cube", "new_superkingdom", "new_taxon_string", "new_taxonomy", "new_user", "new_user_contact"    # );


if __name__ == '__main__':
  shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'vamps2')
  # shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb', 'vamps')
  # 1) get names
  # 2) drop _intermediate"
  # 3) change 454 transfer to intermediate 
  # from 13:27:52 to ... (kill at 2.07 = 40 min)
  # create illumina transfer
  # 4) add illumina transfer to intermediate
  # 5) drop previous
  # 6) swap current to previous
  # 7) swap intermediate to current
  
  print "1) get names"
  norm_tables  = ["new_class", "new_contact", "new_dataset", "new_family", "new_genus", "new_orderx", "new_phylum", "new_project", "new_project_dataset", "new_species", "new_strain", "new_summed_data_cube", "new_superkingdom", "new_taxon_string", "new_taxonomy", "new_user", "new_user_contact"]
  vamps_tables = ["vamps_projects_datasets", "vamps_data_cube", "vamps_junk_data_cube", "vamps_taxonomy", "vamps_sequences", "vamps_export", "vamps_projects_info"]
  all_tables   = norm_tables + vamps_tables
  
  intermediate_names = {}
  intermediate_names.update(vamps_upload_util_class.SqlUtil().add_suffix("_intermediate", all_tables))
  transfer_names = {}
  transfer_names.update(vamps_upload_util_class.SqlUtil().add_suffix("_transfer", all_tables))
  previous_names = {}
  previous_names.update(vamps_upload_util_class.SqlUtil().add_suffix("_previous", all_tables))

  print sys.argv[1]
  if (sys.argv[1] == "drop_interm_and_transfer"):
    vamps_upload_util_class.SqlUtil().drop_tables(all_tables, "_intermediate")
    vamps_upload_util_class.SqlUtil().drop_tables(all_tables, "_transfer")

  if (sys.argv[1] == "454"):
    print "2) Drop _intermediate. Dangerous, because foreign check = 0"
    vamps_upload_util_class.SqlUtil().drop_tables(all_tables, "_intermediate")
    print "3) change 454 transfer to intermediate"  
    vamps_upload_util_class.SqlUtil().swap_vamps_tables("_transfer", "_intermediate", all_tables)
  
  if (sys.argv[1] == "ill"):
    print "4) add illumina transfer to intermediate"
    vamps_upload_util_class.SqlUtil().update_intermediate_from_illumina_transfer(intermediate_names, transfer_names)
  
  if (sys.argv[1] == "rename"):  
    print "5) drop previous"
    vamps_upload_util_class.SqlUtil().drop_tables(all_tables, "_previous")
  
    print "6) swap current to previous"
    vamps_upload_util_class.SqlUtil().swap_vamps_tables("", "_previous", all_tables)
      
    print "7) swap intermediate to current"
    vamps_upload_util_class.SqlUtil().swap_vamps_tables("_intermediate", "", all_tables)

 if (sys.argv[1] == "undo_rename"):  
   print "8) swap current to intermediate"
   vamps_upload_util_class.SqlUtil().swap_vamps_tables("", "_intermediate", all_tables)
     
   print "9) swap previous to current"
   vamps_upload_util_class.SqlUtil().swap_vamps_tables("_previous", "", all_tables)

