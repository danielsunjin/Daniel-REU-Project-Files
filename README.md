# Daniel REU Project: Resting state fMRI based identification of brain networks associated with behavioral traits in mice with human APOE2 alleles

## Introduction

This repository contains information on how I completed the various parts of my 2022 Pratt REU for Meeting the Grand Challenges research project at Duke University.

## Software Dependencies

- ANTs (currently in /install/bin/ in Alex's samos account)
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

Note that RABIES in the fMRI processing scripts is used within a singularity container. SIngularity needs to be installed first and then a RABIES sigularity container needs to be built.  

## Obtaining Functional Connectomes from fMRI

fMRI processing scripts are found in this folder: [fMRI_processing_scripts](https://github.com/danielsunjin/Daniel-REU-Project-Files/tree/main/fMRI_processing_scripts).

### Aquiring Structural and Functional MRI Images and Organizing the Data 

For this project, we aquired structural MRI images and multi-echo resting state functional MRI images of mice brains. These images were aquired on a 7T Bruker 70/20 with a volume RF coil and a 4 channel surface receiver array. We used a T2* EPI protocol with 3 echoes beginning at TE=5 ms and spaced 14.315 ms apart, TR=2252 ms, flip angle=60 degrees, over a field of view of 19.2 x 15 x 9.6 mm, matrix=64 x 50 x 32, and reconstructed at 300 um isotropic resolution. We acquired 600 volumes in 17 minutes. 

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

**Before (original multi-echo fMRI image):**
![image](https://user-images.githubusercontent.com/97412514/180833491-160694f1-5bc6-47d3-b550-d652538f4a39.png)
**After (reoriented multi-echo fMRI image):**
![image](https://user-images.githubusercontent.com/97412514/180833796-aece4c6e-7998-4cb7-a6e5-c065a9d111cd.png)

Note how the left right, anterior posterior, and superior inferior labels now match with the image.

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
 
 **Masked brain:**
 ![image](https://user-images.githubusercontent.com/97412514/180834916-cee38cf5-0087-4317-b73d-eece005c7983.png)


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

**Before (reoriented multi-echo fMRI image):**
![image](https://user-images.githubusercontent.com/97412514/180833796-aece4c6e-7998-4cb7-a6e5-c065a9d111cd.png)
**After (reoriented single-echo brain only fMRI image):**
![image](https://user-images.githubusercontent.com/97412514/180833553-d009a37f-5cdd-4c9e-854b-8fee53ff55c0.png)

### Preprocess the fMRI Images using RABIES

Use the [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) bash script to preprocess the fMRI images using RABIES. The script will also provide a copy of itself along with the time it took to run in a `preprocess.txt` text file in the project folder. Change the `bids_folder` varible to the path of the input BIDS directory that contains the reoriented fMRI images that have been processed to a single echo and contain only the brain (created in the prevous step). Change the `project_folder` varible to the path of a directory that will contain all the RABIES outputs and information regarding preprocessing, confound correction, and analysis for the images in the `bids_folder` directory. Note that in the RABIES call, you may also need to change the path to where the RABIES sif file is installed.

After preprocessing (around 4 hours), use FSLeyes to view the subject fMRI images in the `commonspace_bold` directory with the anatomical template in the `commonspace_resampled_template:` directory of the `bold_dataskink` directory in the `preprocess_outputs` directory of your project folder to make sure that registration occured correctly. The call to RABIES may in [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) may need to be changed if registration does not work well. I find the best RABIES preprocess call is with the `--commonspace_masking` and `--coreg_masking` flags.

RABIES uses the DSURQE mouse atlas for preprocessing, confound correction, and analysis.

**Successful preprocessing:**

Commonspace template with commonspace BOLD:
![image](https://user-images.githubusercontent.com/97412514/180836397-71e03602-8720-4491-b1e1-48f58ea8d209.png)
Commonspace BOLD with commonspace labels:
![image](https://user-images.githubusercontent.com/97412514/180836692-17b2d127-c805-4242-a423-d3c18a3d7e89.png)

### Run Confound Correction on the Preprocess Outputs using RABIES

Use the [confound_correction](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/confound_correction) bash script to run confound correction on the fMRI images using RABIES. The script will also provide a copy of itself along with the time it took to run in a `confound_cor.txt` text file in the project folder. Change the `bids_folder` and `project_folder` variables to be the same as those in the [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) script that produced the preprocessed fMRI images that you want to run confound correction on. Note that in the RABIES call, you may also need to change the path to where the RABIES sif file is installed. The confound corrected images will be in the `cleaned_timeseries` directory in the `confound_correction_datasink` in the `confound_cor_outputs` directory in the project folder.

**Confound corrected BOLD:**
![image](https://user-images.githubusercontent.com/97412514/180837415-79580318-8d80-4ffd-ac68-d621b37df426.png)

### Obtain Functional Connectivity Matrices (Functional Connectomes) from the fMRI images using RABIES

Use the [analysis](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/analysis) bash script to obtain functional connectomes from the fMRI images using rabies. The script will also provide a copy of itself along with the time it took to run in an `analysis.txt` text file in the project folder. Change the `bids_folder` and `project_folder` variables to be the same as those in the [preprocess_2](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/preprocess_2) script and the [confound_correction](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/fMRI_processing_scripts/confound_correction) script that produced the preprocessed, confound corrected fMRI images that you want to get connectomes from. Note that in the RABIES call, you may also need to change the path to where the RABIES sif file is installed.

CSV files containing the functional connectomes will be in the `matrix_data_file` directory in the `analysis_datasink` directory in the `analysis_outputs` directory of the project folder. Figures of the matrices will be in the `matrix_fig` directory in the `analysis_datasink` directory.

**Functional connectivity matrix example:**

![image](https://user-images.githubusercontent.com/97412514/180837495-193cf640-3c8f-4c77-8836-e3d8e7dd76f3.png)

The connectome CSVs will be used later on, so we will need to copy the CSVs from the `matrix_data_file` directory into a new directory and rename each CSV to its correspinding Badea ID (including the underscore) like so:

```
mice_connectomes
├── 220509_1.csv
└── 220509_4.csv
```

## Analyzing Fear Conditioning Data and Obtaining Behavior Metrics

For this project, we analyze fear conditioning behavioral data from the mice. The data and scripts for processing the fear conditioning behavior data can be found in this folder: [new_complete_FC_analysis](https://github.com/danielsunjin/Daniel-REU-Project-Files/tree/main/new_complete_FC_analysis).

Analysis of all the mice can be found in this R markdown file: [analysis.Rmd](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/new_complete_FC_analysis/analysis.Rmd)

Analysis of the 15 APOE2 mice in my project can be found here: [APOE22_analysis.Rmd](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/new_complete_FC_analysis/APOE22_analysis.Rmd)

Note that you will need to change the paths for where images are saved or from where CSVs are read from in these R files.

The fear conditioning experiment can be broken up into 3 days: day 0 (training), day 1 (contextual test), and day 2 (tone test):
![image](https://user-images.githubusercontent.com/97412514/180839411-a96c9319-a05d-4dba-9644-407eada348d7.png)

For day 0, I used a RMANOVA to look at the significance of sex, age, diet, and time to percent freezing time for 15 APOE2 mice. For day 1, I used an ANOVA to look at the significance of sex, age, and diet to percent freezing time for 15 APOE2 mice. For day 2, I used an ANOVA to look at the significance of sex, age, and diet to percent freezing time for 15 APOE2 mice during the pre-tone, tone, and post-tone components of the experiment. For day 2, I did a posthoc on the tone data to see the pairwise comparisons of mice based on sex, age, and diet. I also did a posthoc on the tone data to see the pairwise comparisons of mice based on sex and age within diet.

I also compute the slope of the line of best-fit for the percent-freezing vs time data of each mice during day 0 to get the learning rates of the mice. I use the day 0 learning rate, the day 1 percent freezing time, and the day 2 percent freezing time during the tone as behavior metrics to be used in vertex screening and sparse canonical corelation analysis. These are saved in a file named behavior.rda by the script. 

## Vertex Screening

The [Archive](https://github.com/danielsunjin/Daniel-REU-Project-Files/tree/main/Archive) folder contains the R script for reading the connectome and behavior metrics data and for running vertex screening on the connectomes and behavior metrics. 

The file [r_reader_connectome.R](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Archive/r_reader_connectome.R) reads the connectome and behavior metrics data. Note that the variables storing the path to the master mouse datasheet, the path to the connectomes (the directory with the connectome CSV files that are named by Badea ID), and the path to the behavior.rda file may need to be updated. In this script you can also choose to remove the CSF (cerebral spinal fluid) regions from the analysis in the noreadcsf vector. To list the regions to remove, use this this [excel sheet](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/index_to_region.xlsx):find the name of the CSF regions to remove in column B, and the integers to list in noreadcsf will be the corresponding region indices in column A plus 1 (because RABIES outputs regions in the connectome CSVs starting from 0 whereas R reads starting from 1). This script outputs important data as rda files (noreadcsf.rda, connectivity.rda, and response.rda).

The file [vertex_func.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Archive/vertex_func.py) contains the function `vertex()` for running vertex screening on the data. This function is used in the file [vertex_connectome.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Archive/vertex_connectome.py) to perform vertex screening on the data. The code for `vertex()` needs to be run before using the function in [vertex_connectome.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Archive/vertex_connectome.py). In [vertex_connectome.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Archive/vertex_connectome.py), set the variable `y` to be the behavior metric columns columns of behavior.rda to determine which brain regions are correlated with the behavior metrics.

## Sparse Canonical Correlation Analysis (SCCA)

The [agesexgene](https://github.com/danielsunjin/Daniel-REU-Project-Files/tree/main/agesexgene) folder contains the R script[readandrunplussubnetsnoweight_behavioral.R](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/agesexgene/readandrunplussubnetsnoweight_behavioral.R) that run SCCA on the connectomes and behavior metrics. You will need to run the script twice: once to get the right network figure (saved as short2dnet2.png) and a second time to get the right network table (saved as algo2.csv). In the first run, in order to get the right region indices in the network figure, you will need to run the for loops in lines 315-322. In this first run, the network figure will have the correct region indices, but the network table will have the wrong region indices. In the second run, you will need to comment out the afformentioned for loops in lines 315-322 to get the correct region indices in the network table. In this second run, the network table will have the correct region indices but the network figure will not. At the end of the script is where the violin plots that show how the networks change with different variables is created. You can change the variables in lines 634-638 to plot the networks against different variables (sex, age, diet, etc.). Note that the paths to the rda files created during the vertex screening step and the paths to where images and tables are saved may need to be updated in [readandrunplussubnetsnoweight_behavioral.R](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/agesexgene/readandrunplussubnetsnoweight_behavioral.R).

## Important Things to Note in Vertex Screening and SCCA

The regions in the RABIES connectome outputs CSVs are labeled with indices from 0 to 334, which correspond to regions in the DSURQE mouse atlas. When the connectomes are read by R, however, the columns are read starting from 1 instead of 0 (this is how R works) and we remove some regions because they represent CSF (cerebral spinal fluid) regions. In the vertex screening and SCCA scripts, after running the algorithms, we need to add back the removed regions and shift the regions to start from 0 again to get the correct brain region indices of the DSURQE mouse atlas. In the vertex screening script [vertex_func.py](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Archive/vertex_func.py), lines 177-189 perform this correction. In the SCCA script [readandrunplussubnetsnoweight_behavioral.R](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/agesexgene/readandrunplussubnetsnoweight_behavioral.R), lines 315-322 correct the region indices for the network figure but not the network table, while lines 349-352 and line 468 correct the region indices for the network table but not the network figure. This is why we need multiple runs to get the right network figure and network table, because including lines 315-322 in a run gives the right network figure but messes up the network table and commenting out lines 312-322 in a run messes up the network figure but gives the right network table. To match a DSURQE atlas region to the the RABIES output region indices, use this [excel sheet](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/index_to_region.xlsx), which has the RABIES indices in column A and the DSURQE atlas regions in column B.

## Poster

My REU program poster can be found [here](https://github.com/danielsunjin/Daniel-REU-Project-Files/blob/main/Daniel_Poster_V4.pdf).

## Where Stuff Lives on Samos:

All files related to my project in samos are in `/mnt/paros_WORK/daniel/project`

Directories that start with `pipeline` contain different iterations of RABIES outputs (preprocessing, confound correction, analysis). The directory that contains the best results are the `pipeline_syn_rigid_syn_coreg_masked` directory for the 220404 mice and the `pipeline_BRUKER_data_copy_1` directory for the 220509 mice and some more 220404 mice. 

Directories that start with `project_data` contain MRI files for the 220404 mice and directories that start with `BRUKER` contain MRI files for the 220509 mice and some more 220404 mice. The `BRUKER_data_full_organized_new` and the `project_data` directories contain the original, unprocessed MRI images of the mice. Directories that include `reoriented` contain the reoriented MRI images of the mice. Directories that include `reoriented_with_masks` contain the reoriented MRI images of the mice and masks made in ITK-SNAP of their brains. Directories that include `single_echos` contain the combined multi-echo fMRI images of the mice, and directories that include `single_echos_using_masks` contain the combined multi-echo fMRI images of the mice that have also been skull-stripped correctly using the masks.

Note that the directories that include `renamed` are just directories in which the subject IDs in the names of files and directories in the directory have been renamed to work for RABIES.

The important scripts are:
- `reorient` (reorients fMRI images)
- `process_mGE` (combines multi echoes without using a mask)
- `process_mGE_with_masks` (combines multi echoes with a mask)
- `split_echo.py` (splits multi echo fMRI images)
- `preprocess`, `preprocess_2`, `preprocess_3` (RABIES preprocess scripts that have different RABIES flags)
- `confound_correction` (RABIES confound correction script)
- `analysis` (RABIES analysis script)

## Where Stuff Lives Locally

The unprocessed, straight from BRUKER MRI images are in the `BRUKER` directory in `Documents`. The `pipeline_syn_rigid_syn_coreg_masked` and `pipeline_BRUKER_data_copy_1` directories mentioned in the previous section are in `Downloads`. The `Archive` and `agesexgene` directories that include the scripts for vertex screening and SCCA are also in `Downloads`. The `new_complete_FC_analysis` directory that conatins all the scripts and files for analyzing fear conditioning data is in `Documents`. The poster powerpoints and pdfs are also in `Documents`. Functional connectomes of 15 APOE2 mice are in `FC_matrices` in `Downloads`.



