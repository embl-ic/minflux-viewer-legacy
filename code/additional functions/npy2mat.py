#
# Convert MINFLUX data from numpy format to MATLAB data file:
# 
# modified based on Sheng Liu <shengliu@unm.edu>'s script
# initially created for SMAP <github.com/jries/SMAP>
#
# 1. Select the .npy data file exported from Abberior Imspector software
# 2. The script will convert numpy data into MATLAB .mat data file
# 3. The MATLAB data file exported with this script will be arranged
#     different from Abberior Imspector exported MATLAB data
# 4!!!. It most probably won't work with Abberior's 2024.02.19 software update.
#
# <Ziqiang.Huang@embl.de>
# date: 2024.03.25

import os
import tkinter.filedialog as fd
import numpy as np
import scipy.io as sio


# select numpy data file, multiple selection compatible: 
filelist = fd.askopenfilenames(filetypes = (('numpy file','*.npy'),('all files','*.*')),title = 'choose files')

# go through all .npy files selected
for datafile in filelist:

    res = np.load(datafile)
    resmat = {}
    d1 = res.dtype
    for name1 in d1.names:
        if name1 == 'itr':  # unwrap 'itr' attribute, and copy all attributes into MATLAB structure
            r1 = res[name1]
            #itrnum = r1['itr'].max()
            d2 = r1.dtype
            for name2 in d2.names:
                #resmat[name2] = r1[name2][:,itrnum]
                resmat[name2] = r1[name2]
        else:        
            resmat[name1] = res[name1]

    matfile = os.path.splitext(datafile)[0]+'.mat'
    sio.savemat(matfile,resmat)
