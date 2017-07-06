import vamps_upload_util_class
import sys
import collections
import shared #use shared to call connection from outside of the module

# shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'test')
# shared.my_conn = vamps_upload_util_class.MyConnection('newbpcdb2', 'env454')
# shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb', 'vamps')
# shared.my_conn = vamps_upload_util_class.MyConnection('bpcweb7.bpcservers.private', 'vamps2')

if __name__ == '__main__':
  shared.my_conn = vamps_upload_util_class.MyConnection('vampsdb', 'vamps')
  vamps_upload_util_class.SqlUtil().compare_interm_w_current()

