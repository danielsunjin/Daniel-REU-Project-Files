import nibabel as nib
import os
import numpy as np
import sys

# define paths for the input and output images
imgpath = sys.argv[1]
outpath = sys.argv[2]

if not os.path.isdir(outpath):
    os.mkdir(outpath)

# aquire image data
img = nib.load(imgpath)
data_multi_echo = img.get_data()
affine = img.affine
hdr = img.header

# specify the number of echos
TEs = 3

# iterate over the number of echos and create individual 4D NIfTIs for each echo
for i in np.arange(TEs):
    data_single_echo = data_multi_echo[:,:,:,i::3]
    single_echo_path = os.path.join(outpath, 'echo_' + str(i + 1) + '.nii.gz')
    single_echo_nii = nib.Nifti1Image(data_single_echo, affine, hdr)
    nib.save(single_echo_nii, single_echo_path)

