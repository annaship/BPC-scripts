#!/bioware/python-2.7.2/bin/python
import file_names_w_dataset
import sys
import shared #use shared to call connection from outside of the module

if (len(sys.argv) < 3 or sys.argv[1] == "help" or sys.argv[1] == "-h"):
    print """Please provide rundate and lane.
Ex.: rename_files_to_datasets.py 20130419 1
This script will create file duplicates with project_dataset file names in the current directory.
    """
    
else:
    rundate = sys.argv[1]
    lane    = sys.argv[2]
# path    = sys.argv[3]

    if __name__ == '__main__':
      shared.my_conn = file_names_w_dataset.MyConnection('newbpcdb2', 'env454')
      file_names_w_dataset.File_Names_fromDB(rundate, lane).rename_files_to_pr_dataset()

