/**
 * @ Author: feng
 * @ Create Time: 2023-03-01 10:01:59
 * @ Modified by: feng
 * @ Modified time: 2023-03-01 10:40:13
 * @ Description: save the streamlines masked a roi.
 */

#! /bin/bash
set -uxe

# inputs
proj=/Users/fengsang/Library/CloudStorage/OneDrive-mail.bnu.edu.cn/Learning/L_task-qsiprep
raw=$proj/rawdata
der=$proj/derivatives/sfdwiprep
SUBID=sub-10016
NUMPROC=10

# MNI template path
tplPath=$proj/resource/templateflow/tpl-MNI152NLin2009cAsym
tplMNI152_brain=$tplPath/tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz
roiPath=$proj/resource/RegionsOfInteresting/AT_mask.nii.gz
roiPrefix=AT

subDwiPath=$der/$SUBID/dwi
subAnatPath=$der/$SUBID/anat

# for atlas: mni to t1w
antsApplyTransforms -d 3 \
    -n NearestNeighbor \
    -i $roiPath \
    -o $subAnatPath/mni2t1wRoi_${roiPrefix}.nii.gz \
    -r $subAnatPath/t1w_brain.nii.gz  \
    -t [${subAnatPath}/t1w2mni0GenericAffine.mat,1]  \
    -t $subAnatPath/t1w2mni1InverseWarp.nii.gz
    
# for atlas: t1w to dwi
antsApplyTransforms -d 3 \
    -n NearestNeighbor \
    -i $subAnatPath/mni2t1wRoi_${roiPrefix}.nii.gz \
    -o $subAnatPath/t1w2dwiRoi_${roiPrefix}.nii.gz \
    -r $subDwiPath/b0_brain.nii.gz  \
    -t [${subAnatPath}/t1w2dwi0GenericAffine.mat,1]

tckedit \
    -include $subAnatPath/t1w2dwiRoi_${roiPrefix}.nii.gz \
    $subDwiPath/act_1m.tck \
    $subDwiPath/act_1m_${roiPrefix}.tck

echo "Done."