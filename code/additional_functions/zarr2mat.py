#
# Convert MINFLUX Zarr data to MATLAB data file:
#
# Example of the zarr group hierachy
# /
#  ├── grd
#  │   └── mbm
#  │       ├── R11 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R12 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R17 (3,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R20 (0,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R24 (1,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R31 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R33 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R35 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R38 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R39 (0,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       ├── R5 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  │       └── R7 (749,) [('tim', '<f8'), ('pos', '<f8', (3,)), ('str', '<f8'), ('tid', '<i4')]
#  └── mfx (197120,) [('itr', [('itr', '<i4'), ('tic', '<u8'), ('loc', '<f8', (3,)), ...
#
#   Beamline Monitoring (MBM) Points of Reference
#
# 1. Select the "zarr" folder that copied together with the parent raw data folder (very important)
# 2. The script will convert raw data together with reference point data to MATLAB data file
# 3. The MATLAB data file will be with the same hierarchy as the zarr file

import os
import tkinter.filedialog as fd
import warnings
from pathlib import Path
import zarr
import numpy as np
import scipy.io as sio


# select raw data folder: 
# 1 level above zarr folder, for file name purposes
dir = fd.askdirectory()
if not dir:
    exit()
# locate zarr folder
zarr_dir = os.path.join(dir, 'zarr')
if not os.path.exists(zarr_dir):
    warnings.warn('"zarr" folder not found!')
    exit()

""" sync_dir = os.path.join(dir, 'sync')    
if not os.path.exists(sync_dir):
    warnings.warn('"sync" folder not found!')
    exit() 
"""
# get parent raw data folder
#parent_dir = os.path.dirname(dir); #path.parent.absolute()
#datafile = parent_dir


# open zarr Group hierarchy
arch = zarr.open(zarr_dir)

# inspect zarr Group hierachy
#print(arch.tree())

# prepare MATLAB struct to store data
resmat = {}

# arrange attribute so that the 1st dimension is number of localizations
# be aware of the case of 'loc' or 'pos', where 1 by 3 is possible 
def arrange_array(array):
    if 1==array.ndim: # 1D array in numpy
        return array[np.newaxis].T
    elif 1==len(array): # transpose
        return array.T
    else:
        return array
    
# get MINFLUX raw data
mfx = arch['mfx']
data_mfx = mfx.dtype
#resmat['mfx'] = {}  # in case to reproduce raw data zarr group hierachy
for attr_name in data_mfx.names:
    if attr_name == 'itr':
        itr = mfx['itr']
        #itrnum = r1['itr'].max()
        data_itr = itr.dtype
        for itr_attr_name in data_itr.names:
            #resmat[name2] = r1[name2][:,itrnum]
            resmat[itr_attr_name] = itr[itr_attr_name]
    else:        
        resmat[attr_name] = arrange_array(mfx[attr_name]) # transpose 1D array to N by 1

# get reference point data
data_mbm = arch['grd']['mbm']
resmat['mbm'] = {}
for ref_point in data_mbm:
    R_num = data_mbm[ref_point]
    resmat['mbm'][ref_point] = {}
    data_ref = R_num.dtype
    for attr_ref_name in data_ref.names:
        if attr_ref_name == 'pos':
            resmat['mbm'][ref_point]['pos'] = R_num['pos'] #[np.newaxis].T
        else:
            resmat['mbm'][ref_point][attr_ref_name] = arrange_array(R_num[attr_ref_name]) #[np.newaxis].T

matfile = os.path.splitext(dir)[0]+'.mat'
sio.savemat(matfile, resmat)