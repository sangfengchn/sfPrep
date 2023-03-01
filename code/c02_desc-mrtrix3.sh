#! /bin/bash

# u: undefined variabels will stop, x: display the command, e: error command will stop.
set -uxe
proj=/home/feng/Projects/L_desc-qsiprep
SUBID=sub-10016

# preprocessing
mrconvert sub-10016_run-01_dwi.nii.gz sub-10016_run-01_dwi.mif -fslgrad sub-10016_run-01_dwi.bvec sub-10016_run-01_dwi.bval
mrconvert sub-10016_run-02_dwi.nii.gz sub-10016_run-02_dwi.mif -fslgrad sub-10016_run-02_dwi.bvec sub-10016_run-02_dwi.bval
mrconvert sub-10016_run-03_dwi.nii.gz sub-10016_run-03_dwi.mif -fslgrad sub-10016_run-03_dwi.bvec sub-10016_run-03_dwi.bval

mrcat sub-10016_run-01_dwi.mig sub-10016_run-02_dwi.mig sub-10016_run-03_dwi.mig sub-10016_run-combined_dwi.mig

dwidenoise sub-10016_run-01_dwi.mif sub-10016_run-01_dwi_denoise.mif -force -nthreads 4
# If you don’t see any Gibbs artifacts in your data, then I would recommend omitting this step; we won’t be using it for the rest of the tutorial.
mrdegibbs sub-10016_run-01_dwi_denoise.mif sub-10016_run-01_dwi_degibbs.mif

dwifslpreproc sub-10016_combined_denoise.mif sub-10016_desc-preprocessed_dwi.mif -rpe_none -pe_dir AP -eddy_options " --slm=linear"

# the dash represent the stdout in dwiextract, and represent the stdin in mrmath
dwiextract sub-10016_desc-preprocessed_dwi.mif - -bzero | mrmath - mean sub-10016_desc-b0_dwi.nii.gz -axis 3 -force

bet2 sub-10016_desc-b0_dwi.nii.gz sub-10016_desc-brain_dwi.nii.gz -m -f 0.2

# estimate FODs
dwi2response tournier sub-10016_desc-preprocessed_dwi.mif response.txt -mask sub-10016_desc-brain_mask.nii.gz
dwi2fod csd sub-10016_desc-preprocessed_dwi.mif response.txt wmfod.mif -mask sub-10016_desc-brain_dwi_mask.nii.gz

# preprocesing t1w
antsBrainExtraction.sh -d 3 -a T1w.nii.gz -e /home/feng/Projects/L_desc-qsiprep/resource/templateflow/tpl-MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz -m /home/feng/Projects/L_desc-qsiprep/resource/templateflow/tpl-MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz -o T1w_brain/
mrconvert Brain.nii Brain.mif
5ttgen fsl T1w_brainBrainExtractionBrain.mif 5tt_nocoreg.mif

flirt -ref sub-10016_desc-brain_dwi.nii.gz -in T1w.nii.gz -omat t1w2dwi.mat -o T1w_space-dwi.nii.gz -noresample
