#! /bin/bash
set -uxe

# # inputs
# proj=/Users/fengsang/Library/CloudStorage/OneDrive-mail.bnu.edu.cn/Learning/L_task-qsiprep
# raw=$proj/rawdata
# der=$proj/derivatives/sfdwiprep
# SUBID=sub-10016
# NUMPROC=10

# # MNI template path
# roiPath=$proj/resource/RegionsOfInteresting/AT_mask.nii.gz
# roiPrefix=AT

# inputs
proj=#PROJ#
raw=#RAW#
der=#DER#
SUBID=#SUBID#
NUMPROC=#NUMPROC#

# MNI template path
roiPath=#ROIPATH#
roiPrefix=#ROIPREFIX#

SIMG=#SIMG#

# >>>>>>>>>>> running >>>>>>>>>>>>>>>
subDwiPath=$der/$SUBID/dwi
subAnatPath=$der/$SUBID/anat

# for atlas: mni to t1w
singularity exec $SIMG antsApplyTransforms \
    -d 3 \
    -n NearestNeighbor \
    -i $roiPath \
    -o $subAnatPath/mni2t1wRoi_${roiPrefix}.nii.gz \
    -r $subAnatPath/t1w_brain.nii.gz  \
    -t [${subAnatPath}/t1w2mni0GenericAffine.mat,1]  \
    -t $subAnatPath/t1w2mni1InverseWarp.nii.gz
    
# for atlas: t1w to dwi
singularity exec $SIMG antsApplyTransforms \
    -d 3 \
    -n NearestNeighbor \
    -i $subAnatPath/mni2t1wRoi_${roiPrefix}.nii.gz \
    -o $subAnatPath/t1w2dwiRoi_${roiPrefix}.nii.gz \
    -r $subDwiPath/b0_brain.nii.gz  \
    -t [${subAnatPath}/t1w2dwi0GenericAffine.mat,1]

singularity exec $SIMG tckedit \
    -include $subAnatPath/t1w2dwiRoi_${roiPrefix}.nii.gz \
    -tck_weights_in $subDwiPath/sift_weight.txt \
    -nthreads $NUMPROC \
    $subDwiPath/streamlines.tck \
    $subDwiPath/streamlines_${roiPrefix}.tck

echo "Done."