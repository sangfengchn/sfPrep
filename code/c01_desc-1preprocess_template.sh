#! /bin/bash

# u: undefined variabels will stop, x: display the command, 
# e: error command will stop.
set -uxe

# # inputs
# proj=/Users/fengsang/Library/CloudStorage/OneDrive-mail.bnu.edu.cn/Learning/L_task-qsiprep
# raw=$proj/rawdata
# der=$proj/derivatives/sfdwiprep
# SUBID=sub-10016
# NUMPROC=10

# # MNI template path
# tplPath=$proj/resource/templateflow/tpl-MNI152NLin2009cAsym
# tplMNI152_t1w=$tplPath/tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz
# tplMNI152_brain=$tplPath/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz
# tplMNI152_BrainMask=$tplPath/tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz

# inputs
proj=#PROJ#
raw=#ROW#
der=#DER#
SUBID=#SUBID#
NUMPROC=#NUMPROC#
tplPath=#TPLPATH#
tplMNI152_t1w=#TPLMNI152T1W#
tplMNI152_brain=#TPLMNI152BRAIN#
tplMNI152_BrainMask=#TPLMNI152BRAINMASK#
SIMGMRTRIX3=#SIMGMRTRIX3#
SIMGANTS=#SIMGANTS#

# processing
## >>>>>>>>>>>>>> dwi preprocessing <<<<<<<<<<<<<<<<
cd $proj
subDwiPath=$der/$SUBID/dwi
if [ -d $subDwiPath ]; then
    echo "The directory is already exsited, and it and the files in it will be deleted."
    rm -r $subDwiPath
fi
mkdir -p $subDwiPath
cp $raw/$SUBID/dwi/* $subDwiPath/

# combine all runs
for i in $subDwiPath/*.nii.gz
do
    echo $i
    singularity exec $SIMGMRTRIX3 mrconvert $i ${i/.nii.gz/.mif} -fslgrad ${i/.nii.gz/.bvec} ${i/.nii.gz/.bval}
done
# mrcat need two input at least.
# So when there is a run, we need to rename dwi filename manually.
numOfdwi=`find $subDwiPath -name *_dwi.mif | wc -l`
if [ $numOfdwi -gt 1 ]
then
    singularity exec $SIMGMRTRIX3 mrcat $subDwiPath/*.mif $subDwiPath/dwi.mif
else
    # only have one run of dwi
    for i in `find $subDwiPath -name *_dwi.mif`
    do
        cp $i $subDwiPath/dwi.mif
    done
fi
# denoised, Gibbs ringing removal, and motion corrected.
singularity exec $SIMGMRTRIX3 dwidenoise \
    $subDwiPath/dwi.mif \
    $subDwiPath/dwi_denoised.mif \
    -nthreads $NUMPROC
    
singularity exec $SIMGMRTRIX3 mrdegibbs \
    $subDwiPath/dwi_denoised.mif \
    $subDwiPath/dwi_denoised_unringed.mif \
    -axes 0,1 \
    -nthreads $NUMPROC

singularity exec $SIMGMRTRIX3 dwifslpreproc \
    $subDwiPath/dwi_denoised_unringed.mif \
    $subDwiPath/dwi_preprocessed.mif \
    -rpe_none \
    -pe_dir AP \
    -eddy_options "--slm=linear" \
    -nthreads $NUMPROC
# extract b0 image
singularity exec $SIMGMRTRIX3 dwiextract $subDwiPath/dwi_preprocessed.mif - -bzero | singularity exec $SIMGMRTRIX3 mrmath - mean $subDwiPath/b0.nii.gz -axis 3 -force
singularity exec $SIMGMRTRIX3 bet $subDwiPath/b0.nii.gz $subDwiPath/b0_brain.nii.gz -m -f 0.2

# brain extraction from t1w
subAnatPath=$der/$SUBID/anat
if [ -d $subAnatPath ]; then
    echo "The directory is already exsited, and it and the files in it will be deleted."
    rm -r $subAnatPath
fi
mkdir -p $subAnatPath

cp $raw/$SUBID/anat/${SUBID}_T1w.nii.gz $subAnatPath/t1w.nii.gz
singularity exec $SIMGANTS N4BiasFieldCorrection \
    -d 3 \
    -i $subAnatPath/t1w.nii.gz \
    -o $subAnatPath/t1w_biased.nii.gz \
    -v
singularity exec $SIMGANTS antsBrainExtraction.sh \
    -d 3 \
    -a $subAnatPath/t1w_biased.nii.gz \
    -e $tplMNI152_t1w \
    -m $tplMNI152_BrainMask \
    -o $subAnatPath/tmp/
mv $subAnatPath/tmp/BrainExtractionBrain.nii.gz $subAnatPath/t1w_brain.nii.gz
mv $subAnatPath/tmp/BrainExtractionMask.nii.gz $subAnatPath/t1w_BrainMask.nii.gz
rm -r $subAnatPath/tmp

# t1w to mni
singularity exec $SIMGANTS antsRegistrationSyNQuick.sh \
    -d 3 \
    -f $tplMNI152_brain \
    -m $subAnatPath/t1w_brain.nii.gz \
    -o $subAnatPath/t1w2mni

# t1w to dwi
singularity exec $SIMGANTS antsRegistrationSyNQuick.sh \
    -d 3 \
    -f $subDwiPath/b0_brain.nii.gz \
    -m $subAnatPath/t1w_brain.nii.gz \
    -o $subAnatPath/t1w2dwi \
    -t r

# five-tissues-type, 5TT
singularity exec $SIMGMRTRIX3 5ttgen \
    fsl \
    $subAnatPath/t1w2dwiWarped.nii.gz \
    $subAnatPath/5ttInDwi.nii.gz \
    -sgm_amyg_hipp \
    -premasked \
    -nocrop \
    -force \
    -nthread $NUMPROC

# she interface between white matter and gray matter
singularity exec $SIMGMRTRIX3 5tt2gmwmi \
    $subAnatPath/5ttInDwi.nii.gz \
    $subAnatPath/5ttgmwmiInDwi.nii.gz \
    -force \
    -nthread $NUMPROC

echo "Done."
