/**
 * @ Author: feng
 * @ Create Time: 2023-02-27 11:24:12
 * @ Modified by: feng
 * @ Modified time: 2023-02-28 10:11:31
 * @ Description: The template for preprocessing dwi to generate the structural 
 * @ connectome matrix.
 */

#! /bin/bash

# u: undefined variabels will stop, x: display the command, 
# e: error command will stop.
set -uxe

# inputs
proj=/Users/fengsang/Library/CloudStorage/OneDrive-mail.bnu.edu.cn/Learning/L_task-qsiprep
raw=$proj/rawdata
der=$proj/derivatives/sfdwiprep
SUBID=sub-10016
NUMPROC=10

# MNI template path
tplPath=$proj/resource/templateflow/tpl-MNI152NLin2009cAsym
tplMNI152_t1w=$tplPath/tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz
tplMNI152_brain=$tplPath/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz
tplMNI152_BrainMask=$tplPath/tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz

# processing
## >>>>>>>>>>>>>> dwi preprocessing <<<<<<<<<<<<<<<<
subDwiPath=$der/$SUBID/dwi
if [ ! -d $subDwiPath ]; then
    echo "The directory is already exsited, and it and the files in it will be deleted."
    rm $subDwiPath
    mkdir -p $subDwiPath
fi

# combine all runs
foreach i in $raw/$SUBID/dwi/*.nii.gz
do
    mrconvert $i ${i/.nii.gz/.mif} -fslgrad ${i/.nii.gz/.bvec} ${i/.nii.gz/.bval}
done
mrcat $raw/$SUBID/dwi/*.mif $subDwiPath/dwi.mif
rm $raw/$SUBID/dwi/*.mif

# denoised, Gibbs ringing removal, and motion corrected.
dwidenoise $subDwiPath/dwi.mif $subDwiPath/dwi_denoised.mif
mrdegibbs $subDwiPath/dwi_denoised.mif $subDwiPath/dwi_denoised_unringed.mif \
    -axes 0,1
dwifslpreproc $subDwiPath/dwi_denoised_unringed.mif \
    $subDwiPath/dwi_preprocessed.mif \
    -rpe_none \
    -pe_dir AP \
    -eddy_options "--slm=linear" \
    -nthreads $NUMPROC
# extract b0 image
dwiextract $subDwiPath/dwi_preprocessed.mif - -bzero | mrmath - mean $subDwiPath/b0.nii.gz -axis 3 -force
bet $subDwiPath/b0.nii.gz $subDwiPath/b0_brain.nii.gz -m -f 0.2

# brain extraction from t1w
subAnatPath=$der/$SUBID/anat
if [ ! -d $subAnatPath ]; then
    echo "The directory is already exsited, and it and the files in it will be deleted."
    rm $subAnatPath
    mkdir -p $subAnatPath
fi
cp $raw/$SUBID/anat/${SUBID}_T1w.nii.gz $subAnatPath/t1w.nii.gz
N4BiasFieldCorrection -d 3 \
    -i $subAnatPath/t1w.nii.gz \
    -o $subAnatPath/t1w_biased.nii.gz \
    -v
antsBrainExtraction.sh -d 3 \
    -a $subAnatPath/t1w_biased.nii.gz \
    -e $tplMNI152_t1w \
    -m $tplMNI152_BrainMask \
    -o $subAnatPath/tmp/
mv $subAnatPath/tmp/BrainExtractionBrain.nii.gz $subAnatPath/t1w_brain.nii.gz
mv $subAnatPath/tmp/BrainExtractionMask.nii.gz $subAnatPath/t1w_BrainMask.nii.gz

# t1w to mni
antsRegistrationSyNQuick.sh -d 3 \
    -f $tplMNI152_brain \
    -m $subAnatPath/t1w_brain.nii.gz \
    -o $subAnatPath/t1w2mni

# t1w to dwi
antsRegistrationSyNQuick.sh -d 3 \
    -f $subDwiPath/b0_brain.nii.gz \
    -m $subAnatPath/t1w_brain.nii.gz \
    -o $subAnatPath/t1w2dwi \
    -t 'r'

# five-tissues-type, 5TT
5ttgen fsl \
    $subAnatPath/t1w2dwiWarped.nii.gz \
    $subAnatPath/5ttInDwi.nii.gz \
    -sgm_amyg_hipp \
    -premasked \
    -nocrop \
    -force \
    -nthread $NUMPROC

# she interface between white matter and gray matter
5tt2gmwmi $subAnatPath/5ttInDwi.nii.gz \
    $subAnatPath/5ttgmwmiInDwi.nii.gz \
    -force

echo "Done."
