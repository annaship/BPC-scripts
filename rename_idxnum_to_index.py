#!/bioware/python-2.7.2/bin/python
import rename_idxnum_to_index_class
import sys
import shared #use shared to call connection from outside of the module

if (len(sys.argv) < 3 or sys.argv[1] == "help" or sys.argv[1] == "-h"):
    print """Please provide domain and dna_region.
Ex.: %s bacteria v6 
If your raw file names start with "IDX" (like "IDX8_S8_L001_R2_001") instead of an actual index run %s to rename the files. Run it in the directory with the raw files on any server.
    """ % (sys.argv[0], sys.argv[0])
else:
    domain    = sys.argv[1]
    dna_region = sys.argv[2]
# path    = sys.argv[3]

    if __name__ == '__main__':
    
      shared.my_conn = rename_idxnum_to_index_class.MyConnection('newbpcdb2', 'env454')
      rename_idxnum_to_index_class.Index_Numbers_fromDB(domain, dna_region).rename_files_to_index()
