# Daniel-REU-Project-Files

## Introduction

This repository contains information on how I completed the various parts of my 2022 Pratt REU for Meeting the Grand Challenges research project at Duke University.

## Software Dependencies

- ANTs
- Convert3D
- FSL
- ITK-SNAP
- tedana
- Singularity
- RABIES
- R
- RStudio
- Python
- Java

## Obtaining Functional Connectomes from fMRI

### Aquiring Structural and Functional MRI Images and Organizing the Data 

For this project, we aquired structural MRI images and resting state functional MRI images of mice brains. These images were aquired on a 7T Bruker 70/20 with a volume RF coil and a 4 channel surface receiver array. We used a T2* EPI protocol with 3 echoes beginning at TE=5 ms and spaced 14.315 ms apart, TR=2252 ms, flip angle=60 degrees, over a field of view of 19.2 x 15 x 9.6 mm, matrix=64 x 50 x 32, and reconstructed at 300 um isotropic resolution. We acquired 600 volumes in 17 minutes. 

The images aquired on the Bruker must first be converted to NIfTIs. We are interested in the T1 RARE images (structural images) and T2S EPI images (BOLD images) of the mice, so I extract these images from the mice and organize the files in the BIDS format like so:

```
BRUKER_data_reoriented
├── sub-2205091
│   └── ses-1
│       ├── anat
│       │   └── 13_1_T1_RARE_MEMRI_22mins.nii.gz
│       └── func
│           └── 19_1_T2S_EPI_alex_062122_SE.nii.gz
└── sub-2205094
    └── ses-1
        ├── anat
        │   └── 3_1_T1_RARE_MEMRI_22mins.nii.gz
        └── func
            └── 9_1_T2S_EPI_alex_062122_SE.nii.gz
 ```
 
Some notes about the BIDS format:
- The name of the BIDS directory can be anything. In the above, it is called `BRUKER_data`.
- The `sub-{subject ID}`, `ses-{session ID}`, `anat`, and `func` directories are required for all subjects.
- RIght now, the names of the anatomical (structural) and BOLD (functional) images do not matter.
- Subject IDs must only be numbers. No spaces, underlines, hyphens or letters.
- In my project, there was only one scanning session per subject, so all subjects had only a ses-1 directory. 
 
### Reorienting the Structural and Functional MRI Images
 
The [reorient](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/reorient) script is a bash script that uses ANTs, Convert3D, and FSL to reorient the MRI images so that their labels are correct when viewed in FSLeyes. When using the [reorient](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/reorient) script, change the `lab_data` and `lab_data_reoriented` variables in the script to the path of the directory with the anatomical and BOLD images of the mice (created in the previous step) and the path of the outputs of the script respectively. 

The reorient script also renames the anatomical and bold files so that they can be used by RABIES later on like so:

```
BRUKER_data_reoriented
├── sub-2205091
│   └── ses-1
│       ├── anat
│       │   └── sub-2205091_ses-1_T1w.nii.gz
│       └── func
│           └── sub-2205091_ses-1_run-1_bold.nii.gz
└── sub-2205094
    └── ses-1
        ├── anat
        │   └── sub-2205094_ses-1_T1w.nii.gz
        └── func
            └── sub-2205094_ses-1_run-1_bold.nii.gz
 ```

RABIES requires that the anatomical images have a `T1w` or `T2w` suffix, the bold images have a `bold` suffix, and that `run-{run #}` be included in the names of the BOLD images if multiple fMRI images were taken of the subject in one session.

### Making Masks of the Brain in the fMRI Images

After reorienting the images, we need to optimally combine the multiple echoes of the fMRI images and extract the brain in the fMRI images. To do this, I first create masks of the brain in the reoriented fMRI images using the paintbrush tool in ITK-SNAP. Another faster way to make the masks is to use the active contour feature of ITK-SNAP, and then use the paintbrush tool to edit the results. To use the active contour tool, click on active contour in the main toolbox section on the left side of ITK-SNAP, move the borders to include the whole brain, and click on segment 3D. Next, adjust the threshholding to include most of the mouse brain and leave out most of the other stuff (click on More ... for more options when doing this). Next, add bubbles within the brain that will grow to cover the brain. Finally, set the parameters of the active contour such that when you press play, the mask mainly covers the brain and little else. This will require some trial and error tinkering. name the masks `mask.nii.gz`.

After making the brain masks, edit the BIDS directory of the reoriented images to include a `run-{run #}` directory in the `func` directory of each subject for each fMRI image taken of the subject. Next, move each fMRI image into its own `run-{run #}` directory along with the mask made for the image. This directory will be the input into the [process_mGE_with_masks script](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/process_mGE_with_masks) and should look like so:

```
BRUKER_data_reoriented_with_masks
├── sub-2205091
│   └── ses-1
│       ├── anat
│       │   └── sub-2205091_ses-1_T1w.nii.gz
│       └── func
│           └── run-1
│               └── mask.nii.gz
│               └── sub-2205091_ses-1_run-1_bold.nii.gz
└── sub-2205094
    └── ses-1
        ├── anat
        │   └── sub-2205094_ses-1_T1w.nii.gz
        └── func
            └── run-1
                └── mask.nii.gz
                └── sub-2205094_ses-1_run-1_bold.nii.gz
 ```

### Process the Multi-Echo fMRI Images and Extract the Brain

The [process_mGE_with_masks script](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/process_mGE_with_masks) bash script extracts the brain from the fMRI images and combines the mutliple echoes of each image into a single echo image using tedana and the [split_echo.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/split_echo.py) script. When using the [process_mGE_with_masks script](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/process_mGE_with_masks) script, change the `input_dir` and `output_dir` variables to the path of directory with the roeriented anatomical and BOLD images with the brain masks (created in the previous step) and the path of the outputs of the script respectively. Also make sure that the path to the [split_echo.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/split_echo.py) script stored in the `python_split_echo_script` variable is correct. The output should look like so:

```
BRUKER_data_reoriented_single_echoes
├── sub-2205091
│   └── ses-1
│       ├── anat
│       │   └── sub-2205091_ses-1_T1w.nii.gz
│       └── func
│           └── sub-2205091_ses-1_run-1_bold.nii.gz
└── sub-2205094
    └── ses-1
        ├── anat
        │   └── sub-2205094_ses-1_T1w.nii.gz
        └── func
            └── sub-2205094_ses-1_run-1_bold.nii.gz
 ```

Notice that this script outputs the images in a BIDS format.

### Preprocess the fMRI Images using RABIES

Use the [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) bash script to preprocess the fMRI images using RABIES. Change the `bids_folder` varible to the path of the input BIDS directory that contains the reoriented fMRI images that have been processed to a single echo and contain only the brain (created in the prevous step). Change the `project_folder` varible to the path of a directory that will contain all the RABIES outputs and information regarding preprocessing, confound correction, and analysis for the images in the `bids_folder` directory. 

After preprocessing (around 4 hours), use FSLeyes to view the subject fMRI images in the `commonspace_bold` directory with the anatomical template in the `commonspace_resampled_template:` directory of the `bold_dataskink` directory in the `preprocess_outputs` directory of your project folder to make sure that registration occured correctly. The call to RABIES may in [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) may need to be changed if registration does not work well. I find the best RABIES preprocess call is with the `--commonspace_masking` and `--coreg_masking` flags.

### Run Confound Correction on the Preprocess Outputs using RABIES

Use the [confound_correction](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/confound_correction) bash script to run confound correction on the fMRI images using RABIES. Change the `bids_folder` and `project_folder` variables to be the same as those in the [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) script that produced the preprocessed fMRI images that you want to run confound correction on. 

### Obtain Functional Connectivity Matrices (Functional Connectomes) from the fMRI images using RABIES

Use the [analysis](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/analysis) bash script to obtain functional connectomes from the fMRI images using rabies. Change the `bids_folder` and `project_folder` variables to be the same as those in the [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) script and the [confound_correction](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/confound_correction) script that produced the preprocessed, confound corrected fMRI images that you want to get connectomes from. 

## Analyzing Fear Conditioning Data and Obtaining Behavior Metrics

For this project, we analyze fear conditioning behavioral data from the mice. 
