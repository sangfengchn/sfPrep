#! /bin/bash

# u: undefined variabels will stop, x: display the command, e: error command will stop.
set -uxe
proj=/home/feng/Projects/L_desc-qsiprep
SUBID=sub-10016
SIMG=/home/feng/Envs/qsiprep-0.16.1

# preprocessing
singularity exec $SIMG qsiprep \
    $proj/rawdata/ \
    $proj/derivatives/ \
    participant \
    --participant-label $SUBID \
    --output-resolution 1.0 \
    --output-space template \
    --use-syn-sdc \
    --distortion-group-merge concat \
    --denoise-after-combining \
    --fs-license-file $SIMG/../license.txt \
    -w $proj/work/ \
    --nthreads 4 \
    --omp-nthreads 2 \
    --write-graph \
    --stop-on-first-crash \
    --notrack \
    -v

# reconstruction
# singularity exec $SIMG qsiprep \
#     rawdata/ \
#     derivatives/ \
#     participant \
#     --participant-label $SUBID \
#     --output-resolution 1.0 \
#     --fs-license-file $SIMG/../license.txt \
#     -w work/ \
#     --recon-only \
#     --recon-input derivatives/qsiprep/ \
#     --recon-spec mrtrix_singleshell_ss3t_noACT \
#     --nthreads 4 \
#     --omp-nthreads 2 \
#     --low-mem \
#     -v

# singularity exec -e $SIMG qsiprep \
#     rawdata/ derivatives/ participant \
#     --participant-label 10016 \
#     -w work/  \
#     --output-resolution 1.0 \
#     --force-syn \
#     --recon-input derivatives/qsiprep \
#     --recon-spec mrtrix_singleshell_ss3t_ACT-hsvs \
#     --freesurfer-input derivatives/freesurfer \
#     --fs-license-file $SIMG/../license.txt \
#     -v \
#     --write-graph \
#     --stop-on-first-crash

echo "Done."
