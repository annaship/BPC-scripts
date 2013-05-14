import file_names_w_dataset
import shared #use shared to call connection from outside of the module

if __name__ == '__main__':
    
  shared.my_conn = file_names_w_dataset.MyConnection('newbpcdb2', 'env454')
  file_names_w_dataset.File_Names_fromDB().remove_all_new_files()

