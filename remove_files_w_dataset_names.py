import file_names_w_dataset
import shared #use shared to call connection from outside of the module

# shared.my_conn = vamps_upload_util_class.MyConnection(server_name = 'bpcdb2')
# shared.my_conn = vamps_upload_util_class.MyConnection(server_name = 'vampsdb')
# shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'test')
# shared.my_conn = vamps_upload_util_class.MyConnection('newbpcdb2', 'env454')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb', 'vamps')
# shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'vamps2')

if __name__ == '__main__':
  shared.my_conn = file_names_w_dataset.MyConnection('newbpcdb2', 'env454')
  file_names_w_dataset.File_Names_fromDB().remove_all_new_files()

