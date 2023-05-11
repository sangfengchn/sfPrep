'''
 # @ Author: feng
 # @ Create Time: 2023-05-10 14:07:08
 # @ Modified by: feng
 # @ Modified time: 2023-05-10 14:07:11
 # @ Description: submit the interrupted jobs.
 '''

import os
from os.path import join as opj
from glob import glob
import re
import time
import shutil
import subprocess
import logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(message)s"
)

def func_jobNumber(queneName):
    cli = f'squeue | grep {queneName}'
    resCli = os.popen(cli).readlines()
    return len(resCli)

def func_submit(proj, rawdata, derivatives, subId, jobName, simgMrtrix3, simgANTs, atlasPath, roisPath, numProc, queue):
    cli = (
        "#! /bin/bash\n\n"
        f"#SBATCH --job-name={jobName}\n"
        "#SBATCH -n 1\n"
        f"#SBATCH -c {numProc}\n"
        f"#SBATCH -o {derivatives}/{subId}/log/dwiprep.log\n"
        f"#SBATCH -e {derivatives}/{subId}/log/dwiprep.err\n"
        f"#SBATCH -p {queue}\n"
        "source /public1/soft/modules/module.sh\n"
        "module load anaconda/3-Python-3.8.3-phonopy-phono3py\n"
        "module load singularity/3.8.4\n"
        f"cd {proj}\n"
        f"python {proj}/code/c01_desc-RunningAppend_sbatch.py --proj {proj} --rawdata {rawdata} --derivatives {derivatives} --participant_id {subId} --simg_mrtrix {simgMrtrix3} --simg_ants {simgANTs} --atlas_path {atlasPath} --rois_path {roisPath} --num_proc {numProc}\n"
        "echo 'Congraduation! Job has been finished!'\n"
    )
    try:
        p = subprocess.run(f"sbatch -J {jobName}", input=cli, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)


if __name__ == "__main__":
    # proj paths
    proj = "/public1/home/sch3155/feng/Projects/S_task-mrtrix3"
    raw = opj(proj, "rawdata")
    der = opj(proj, "derivatives", "sfprep")
    
    simgMrtrix3 = "/public1/home/sch3155/feng/Envs/mrtrix3.simg"
    simgANTs = "/public1/home/sch3155/feng/Envs/ants-centos7.simg"
    # atlas is for construction connectome matrix
    atlasPath = opj(proj, "resource", "templateflow", "tpl-MNI152NLin2009cAsym")
    # roi is used to filter the whole fiber, and save the fiber that cross roi
    roisPath = opj(proj, "resource", "RegionsOfInteresting")
    
    # config queue
    numProc = 12
    numJobLimit = 10
    queueName = "v6_384"
    
    # for each participants
    for i in glob(opj(der, "sub-*")):
        subId = os.path.split(i)[-1]
        # if subId != "sub-BNU1": continue
        if os.path.exists(opj(i, "log", "copied")): continue
        
        # the preprocess need dwi and t1w
        if not (os.path.exists(opj(i, "anat")) or os.path.exists(opj(i, "dwi"))): continue
        
        # don't exceed the limition of job in queue
        # while func_jobNumber(queneName=queueName) >= numJobLimit: time.sleep(120)
        
        subDerPath = opj(der, subId)
        subLogPath = opj(subDerPath, "log")
        if not os.path.exists(subLogPath): os.makedirs(subLogPath)
        # if (os.path.exists(opj(subLogPath, "submited")) or
        #     os.path.exists(opj(subLogPath, "running")) or
        #     os.path.exists(opj(subLogPath, "finished")) or
        #     os.path.exists(opj(subLogPath, "copied"))):
        #     continue
        if not os.path.exists(opj(subDerPath, "anat", "5ttgmwmiInDwi.nii.gz")): continue
        
        logging.info(subId)
        with open(opj(subLogPath, "submited"), "w") as f: f.writelines("")
        func_submit(proj=proj,
                    rawdata=raw, 
                    derivatives=der, 
                    subId=subId, 
                    jobName=f"dwi{subId}", 
                    simgMrtrix3=simgMrtrix3, 
                    simgANTs=simgANTs, 
                    atlasPath=atlasPath, 
                    roisPath=roisPath, 
                    numProc=numProc, 
                    queue=queueName)
    logging.info("Submit done.")
