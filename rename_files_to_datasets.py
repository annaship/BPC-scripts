import file_names_w_dataset
import sys
import shared #use shared to call connection from outside of the module

print 'sys.argv = '
print sys.argv
rundate = sys.argv[1]
lane    = sys.argv[2]
# path    = sys.argv[3]

if __name__ == '__main__':
  shared.my_conn = file_names_w_dataset.MyConnection('newbpcdb2', 'env454')
  file_names_w_dataset.File_Names_fromDB(rundate).rename_files_to_pr_dataset()

