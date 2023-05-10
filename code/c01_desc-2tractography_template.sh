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

proj=#PROJ#
raw=#RAW#
der=#DER#
SUBID=#SUBID#
NUMPROC=#NUMPROC#

SIMGMRTRIX3=#SIMGMRTRIX3#
SIMGANTS=#SIMGANTS#

# >>>>>>>>>> running >>>>>>>>>>>>>
cd $proj
NUMSTREAMLINES=50M
subDwiPath=$der/$SUBID/dwi
subAnatPath=$der/$SUBID/anat

# # response and FODs
# # singularity exec $SIMG dwi2response dhollander \
# #     $subDwiPath/dwi_preprocessed.mif \
# #     $subDwiPath/wm_response.txt \
# #     $subDwiPath/gm_response.txt \
# #     $subDwiPath/csf_response.txt \
# #     -mask $subDwiPath/b0_brain_mask.nii.gz
# singularity exec $SIMGMRTRIX3 dwi2response \
#     msmt_5tt \
#     $subDwiPath/dwi_preprocessed.mif \
#     $subAnatPath/5ttInDwi.nii.gz \
#     $subDwiPath/wm_response_msmt5tt.txt \
#     $subDwiPath/gm_response_msmt5tt.txt \
#     $subDwiPath/csf_response_msmt5tt.txt \
#     -sfwm_fa_threshold 0.7 \
#     -nthreads $NUMPROC

# # If only two unique b-values are available, it’s also possible to estimate only two tissue compartments, e.g., white matter and CSF. (https://mrtrix.readthedocs.io/en/latest/reference/commands/dwi2fod.html)
# singularity exec $SIMGMRTRIX3 dwi2fod \
#     msmt_csd \
#     $subDwiPath/dwi_preprocessed.mif \
#     $subDwiPath/wm_response_msmt5tt.txt \
#     $subDwiPath/wmfod_msmt5tt.mif \
#     $subDwiPath/csf_response_msmt5tt.txt \
#     $subDwiPath/csffod_msmt5tt.mif \
#     -force

# # tractography
# singularity exec $SIMGMRTRIX3 tckgen \
#     $subDwiPath/wmfod_msmt5tt.mif \
#     $subDwiPath/streamlines.tck \
#     -algorithm iFOD2 \
#     -minlength 3 \
#     -maxlength 250 \
#     -angle 45 \
#     -step 0.2 \
#     -cutoff 0.05 \
#     -seed_gmwmi $subAnatPath/5ttgmwmiInDwi.nii.gz \
#     -act $subAnatPath/5ttInDwi.nii.gz \
#     -backtrack \
#     -crop_at_gmwmi \
#     -force \
#     -select $NUMSTREAMLINES \
#     -nthreads $NUMPROC

singularity exec $SIMGMRTRIX3 tcksift2 \
    -act $subAnatPath/5ttInDwi.nii.gz \
    -out_mu $subDwiPath/sift_mu.txt \
    -out_coeffs $subDwiPath/sift_coeffs.txt \
    -nthreads $NUMPROC \
    $subDwiPath/streamlines.tck \
    $subDwiPath/wmfod_msmt5tt.mif \
    $subDwiPath/sift_weight.txt    

echo "Done."
