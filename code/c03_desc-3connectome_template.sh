/**
 * @ Author: feng
 * @ Create Time: 2023-02-27 11:24:12
 * @ Modified by: feng
 * @ Modified time: 2023-03-01 10:03:21
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
tplMNI152_atlas=$tplPath/tpl-MNI152NLin2009cAsym_res-02_atlas-Schaefer2018_desc-100Parcels7Networks_dseg.nii.gz
tplMNI152_atlasLUT=$tplPath/tpl-MNI152NLin2009cAsym_atlas-Schaefer2018_desc-100Parcels7Networks_dseg_mrlut.txt
tplMNI152_atlasPrefix=100Parcels7Networks

# connectoming
subDwiPath=$der/$SUBID/dwi
subAnatPath=$der/$SUBID/anat

# for atlas: mni to t1w
antsApplyTransforms -d 3 \
    -n NearestNeighbor \
    -i $tplMNI152_atlas \
    -o $subAnatPath/mni2t1wAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    -r $subAnatPath/t1w_brain.nii.gz  \
    -t [${subAnatPath}/t1w2mni0GenericAffine.mat,1]  \
    -t $subAnatPath/t1w2mni1InverseWarp.nii.gz
# for atlas: t1w to dwi
antsApplyTransforms -d 3 \
    -n NearestNeighbor \
    -i $subAnatPath/mni2t1wAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    -o $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    -r $subDwiPath/b0_brain.nii.gz  \
    -t [${subAnatPath}/t1w2dwi0GenericAffine.mat,1]

# relabeled, this step can be removed
labelconvert \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    $tplMNI152_atlasLUT \
    $tplMNI152_atlasLUT \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.mif

# matrix: number of streamlines
tck2connectome \
    $subDwiPath/act_1m.tck \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.mif \
    $subDwiPath/mat_NumberOfStreamlines_${tplMNI152_atlasPrefix}.csv \
    -tck_weights_in $subDwiPath/sift_1m.txt \
    -out_assignments $subDwiPath/assignments.txt \
    -symmetric

# matrix: length of streamlines
tck2connectome \
    $subDwiPath/act_1m.tck \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.mif \
    $subDwiPath/mat_LengthOfStreamlines_${tplMNI152_atlasPrefix}.csv \
    -tck_weights_in $subDwiPath/sift_1m.txt \
    -scale_length \
    -stat_edge mean \
    -symmetric

echo "Done."
