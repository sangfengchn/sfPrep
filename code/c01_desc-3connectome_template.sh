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
# tplMNI152_atlas=$tplPath/tpl-MNI152NLin2009cAsym_res-02_atlas-Schaefer2018_desc-100Parcels7Networks_dseg.nii.gz
# tplMNI152_atlasLUT=$tplPath/tpl-MNI152NLin2009cAsym_atlas-Schaefer2018_desc-100Parcels7Networks_dseg_mrlut.txt
# tplMNI152_atlasPrefix=100Parcels7Networks

# inputs
proj=#PROJ#
raw=#RAW#
der=#DER#
SUBID=#SUBID#
NUMPROC=#NUMPROC#

tplMNI152_atlas=#TPLMNI152ATLAS#
tplMNI152_atlasLUT=#TPLMNI152ATLASLUT#
tplMNI152_atlasPrefix=#ATLASPREFIX#

SIMGMRTRIX3=#SIMGMRTRIX3#
SIMGANTS=#SIMGANTS#

# connectoming
cd $proj
subDwiPath=$der/$SUBID/dwi
subAnatPath=$der/$SUBID/anat
subNetPath=$der/$SUBID/net
[ ! -d $subNetPath ] && mkdir -p $subNetPath

# for atlas: mni to t1w
singularity exec $SIMGANTS antsApplyTransforms -d 3 \
    -n NearestNeighbor \
    -i $tplMNI152_atlas \
    -o $subAnatPath/mni2t1wAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    -r $subAnatPath/t1w_brain.nii.gz  \
    -t [${subAnatPath}/t1w2mni0GenericAffine.mat,1]  \
    -t $subAnatPath/t1w2mni1InverseWarp.nii.gz
# for atlas: t1w to dwi
singularity exec $SIMGANTS antsApplyTransforms -d 3 \
    -n NearestNeighbor \
    -i $subAnatPath/mni2t1wAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    -o $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    -r $subDwiPath/b0_brain.nii.gz  \
    -t [${subAnatPath}/t1w2dwi0GenericAffine.mat,1]

# relabeled, this step can be removed
singularity exec $SIMGMRTRIX3 labelconvert \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.nii.gz \
    $tplMNI152_atlasLUT \
    $tplMNI152_atlasLUT \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.mif \
    -force

# matrix: number of streamlines
singularity exec $SIMGMRTRIX3 tck2connectome \
    $subDwiPath/streamlines.tck \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.mif \
    $subDwiPath/mat_NumberOfStreamlines_${tplMNI152_atlasPrefix}.csv \
    -tck_weights_in $subDwiPath/sift_weight.txt \
    -out_assignments $subDwiPath/assignments.txt \
    -symmetric \
    -nthreads $NUMPROC \
    -force
mv $subDwiPath/mat_NumberOfStreamlines_${tplMNI152_atlasPrefix}.csv $subNetPath/mat_NumberOfStreamlines_${tplMNI152_atlasPrefix}.csv

# matrix: length of streamlines
singularity exec $SIMGMRTRIX3 tck2connectome \
    $subDwiPath/streamlines.tck \
    $subAnatPath/t1w2dwiAtlas_${tplMNI152_atlasPrefix}.mif \
    $subDwiPath/mat_LengthOfStreamlines_${tplMNI152_atlasPrefix}.csv \
    -tck_weights_in $subDwiPath/sift_weight.txt \
    -scale_length \
    -stat_edge mean \
    -symmetric \
    -nthreads $NUMPROC \
    -force
mv $subDwiPath/mat_LengthOfStreamlines_${tplMNI152_atlasPrefix}.csv $subNetPath/mat_LengthOfStreamlines_${tplMNI152_atlasPrefix}.csv

echo "Done."
