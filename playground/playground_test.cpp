#include "src/hdf5.h"
#include <assert.h>

int main(int, char**) {
   hid_t  f = H5Fopen("/home/volker/mnt/eiger_data/E-32-0100/test_PSI/lyso1_18_20150923/lyso1_18_master.h5", H5F_ACC_RDONLY, H5P_DEFAULT);
   assert(f>0);
   // H5L_info_t link_buff;
   // herr_t  err = H5Lget_info( f, "/entry/data/data_000001", &link_buff, H5P_DEFAULT);
   char buf[1024];
   herr_t  err = H5Lget_val(f, "/entry/data/data_000003", &buf, sizeof(buf), H5P_DEFAULT);
   assert(err == 0);
}