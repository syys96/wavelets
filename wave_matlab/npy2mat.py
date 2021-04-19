import numpy as np
import getopt
import sys
from scipy.io import savemat


def trans_op(npy_lists, save_dir='.'):
    for npy in npy_lists:
        data = np.load(npy)
        save_path = save_dir+'/'+npy.split('.')[0]+'.mat'
        print("save in: ", save_path)
        savemat(save_path,\
             {'data': data})


if __name__ == "__main__":
    assert sys.argv[0] == 'npy2mat.py'
    save_dir = '.'
    try:
        opts, args = getopt.getopt(sys.argv[1:], \
            "hs:", ["help", "save_dir="])
    except getopt.GetoptError:
        print('Error: npy2mat.py -r <dir_to_save> file1 file2 ...')
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print('Error: npy2mat.py -r <dir_to_save> file1 file2 ...')
            sys.exit()
        elif opt in ("-s", "--save_dir"):
            save_dir = arg
    print("trans op on: ", args)
    trans_op(args, save_dir)
