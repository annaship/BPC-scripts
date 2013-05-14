import vamps_upload_util_class
import sys
import collections
import shared #use shared to call connection from outside of the module

# shared.my_conn = vamps_upload_util_class.MyConnection(server_name = 'bpcdb2')
# shared.my_conn = vamps_upload_util_class.MyConnection(server_name = 'vampsdb')
# shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'test')
# shared.my_conn = vamps_upload_util_class.MyConnection('newbpcdb2', 'env454')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb', 'vamps')
# shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'vamps2')

if __name__ == '__main__':
  shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb', 'vamps')
#  shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'vamps2')
  vamps_upload_util_class.SqlUtil().compare_res_w_previous(table_list = ["vamps_data_cube", "vamps_export", "vamps_junk_data_cube", "vamps_projects_datasets", "vamps_sequences", "vamps_taxonomy"])

