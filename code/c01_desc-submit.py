'''
 # @ Author: feng
 # @ Create Time: 2023-03-01 15:32:25
 # @ Modified by: feng
 # @ Modified time: 2023-03-01 15:32:27
 # @ Description: submit the pipeline.
 '''

import os
from os.path import join as opj
from glob import glob
import re
import shutil
import subprocess
import logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(message)s"
)

def func_Preprocessing(codeTplPath, projPath, rawPath, derPath, subId, numProc, tplPath, tplT1wPath, tplBrainPath, tplBrainMaskPath, simgMrtrix3, simgANTs):
    with open(codeTplPath, "r") as f:
        codeStr = f.readlines()
    codeStr = [re.sub("#PROJ#", projPath, i) for i in codeStr]
    codeStr = [re.sub("#ROW#", rawPath, i) for i in codeStr]
    codeStr = [re.sub("#DER#", derPath, i) for i in codeStr]
    codeStr = [re.sub("#SUBID#", subId, i) for i in codeStr]
    codeStr = [re.sub("#NUMPROC#", str(numProc), i) for i in codeStr]
    codeStr = [re.sub("#TPLPATH#", tplPath, i) for i in codeStr]
    codeStr = [re.sub("#TPLMNI152T1W#", tplT1wPath, i) for i in codeStr]
    codeStr = [re.sub("#TPLMNI152BRAIN#", tplBrainPath, i) for i in codeStr]
    codeStr = [re.sub("#TPLMNI152BRAINMASK#", tplBrainMaskPath, i) for i in codeStr]
    codeStr = [re.sub("#SIMGMRTRIX3#", simgMrtrix3, i) for i in codeStr]
    codeStr = [re.sub("#SIMGANTS#", simgANTs, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)
    
def func_Tractography(codeTplPath, projPath, rawPath, derPath, subId, numProc, simgMrtrix3, simgANTs):
    with open(codeTplPath, "r") as f:
        codeStr = f.readlines()
    codeStr = [re.sub("#PROJ#", projPath, i) for i in codeStr]
    codeStr = [re.sub("#RAW#", rawPath, i) for i in codeStr]
    codeStr = [re.sub("#DER#", derPath, i) for i in codeStr]
    codeStr = [re.sub("#SUBID#", subId, i) for i in codeStr]
    codeStr = [re.sub("#NUMPROC#", str(numProc), i) for i in codeStr]
    codeStr = [re.sub("#SIMGMRTRIX3#", simgMrtrix3, i) for i in codeStr]
    codeStr = [re.sub("#SIMGANTS#", simgANTs, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)
    
def func_Connectome(codeTplPath, projPath, rawPath, derPath, subId, numProc, tplMNI152Atlas, tplMNI152AtlasLut, tplMNI152AtlasPrefix, simgMrtrix3, simgANTs):
    with open(codeTplPath, "r") as f:
        codeStr = f.readlines()
    codeStr = [re.sub("#PROJ#", projPath, i) for i in codeStr]
    codeStr = [re.sub("#RAW#", rawPath, i) for i in codeStr]
    codeStr = [re.sub("#DER#", derPath, i) for i in codeStr]
    codeStr = [re.sub("#SUBID#", subId, i) for i in codeStr]
    codeStr = [re.sub("#NUMPROC#", str(numProc), i) for i in codeStr]
    codeStr = [re.sub("#TPLMNI152ATLAS#", tplMNI152Atlas, i) for i in codeStr]
    codeStr = [re.sub("#TPLMNI152ATLASLUT#", tplMNI152AtlasLut, i) for i in codeStr]
    codeStr = [re.sub("#ATLASPREFIX#", tplMNI152AtlasPrefix, i) for i in codeStr]
    codeStr = [re.sub("#SIMGMRTRIX3#", simgMrtrix3, i) for i in codeStr]
    codeStr = [re.sub("#SIMGANTS#", simgANTs, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)

def func_Filtered(codeTplPath, projPath, rawPath, derPath, subId, numProc, roiPath, roiPrefix, simgMrtrix3, simgANTs):
    with open(codeTplPath, "r") as f:
        codeStr = f.readlines()
    codeStr = [re.sub("#PROJ#", projPath, i) for i in codeStr]
    codeStr = [re.sub("#RAW#", rawPath, i) for i in codeStr]
    codeStr = [re.sub("#DER#", derPath, i) for i in codeStr]
    codeStr = [re.sub("#SUBID#", subId, i) for i in codeStr]
    codeStr = [re.sub("#NUMPROC#", str(numProc), i) for i in codeStr]
    codeStr = [re.sub("#ROIPATH#", roiPath, i) for i in codeStr]
    codeStr = [re.sub("#ROIPREFIX#", roiPrefix, i) for i in codeStr]
    codeStr = [re.sub("#SIMGMRTRIX3#", simgMrtrix3, i) for i in codeStr]
    codeStr = [re.sub("#SIMGANTS#", simgANTs, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)


if __name__ == "__main__":
    # proj paths
    proj = "/home/feng/Projects/L_desc-qsiprep"
    raw = opj(proj, "rawdata")
    der = opj(proj, "derivatives", "sfprep")
    
    # the number of threads
    numProc = 6

    # path of enviroment images
    simgMrtrix3 = opj(proj, "..", "..", "Envs", "qsiprep-0.16.1")
    simgANTs = simgMrtrix3
    
    # path of template for brain extraction and registration
    tplPath = opj(proj, "resource", "templateflow", "tpl-MNI152NLin2009cAsym")
    tplT1wPath = opj(tplPath, "tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz")
    tplBrainPath = opj(tplPath, "tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz")
    tplBrainMaskPath = opj(tplPath, "tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz")
    
    # paths of template scripts
    step1TplPath = opj(proj, "code", "c01_desc-1preprocess_template.sh")
    step2TplPath = opj(proj, "code", "c01_desc-2tractography_template.sh")
    step3TplPath = opj(proj, "code", "c01_desc-3connectome_template.sh")
    step4TplPath = opj(proj, "code", "c01_desc-4filtered_template.sh")
    
    # atlas is for construction connectome matrix
    atlasPaths = glob(opj(proj, "resource", "templateflow", "tpl-MNI152NLin2009cAsym", "*_dseg.nii.gz"))
    
    # roi is used to filter the whole fiber, and save the fiber that cross roi
    roiPaths = glob(opj(proj, "resource", "RegionsOfInteresting", "*.nii.gz"))
    
    # for each participants
    for i in glob(opj(raw, "sub-*")):
        subId = os.path.split(i)[-1]
        subOutPath = opj(der, subId)
        subLogPath = opj(subOutPath, "log")
        if not os.path.exists(subLogPath): os.makedirs(subLogPath)
        if (os.path.exists(opj(subLogPath, "submited")) or
            os.path.exists(opj(subLogPath, "running")) or
            os.path.exists(opj(subLogPath, "finished"))): continue
        
        logging.info(subId)
        # with open(opj(subLogPath, "submited"), "w") as f: f.writelines("")
        # func_Preprocessing(
        #     codeTplPath=step1TplPath,
        #     projPath=proj,
        #     rawPath=os.path.split(i)[0],
        #     derPath=der,
        #     subId=subId,
        #     numProc=numProc,
        #     tplPath=tplPath,
        #     tplT1wPath=tplT1wPath,
        #     tplBrainPath=tplBrainPath,
        #     tplBrainMaskPath=tplBrainMaskPath,
        #     simgMrtrix3=simgMrtrix3,
        #     simgANTs=simgANTs
        #     )
        
        # func_Tractography(
        #     codeTplPath=step2TplPath,
        #     projPath=proj,
        #     rawPath=os.path.split(i)[0],
        #     derPath=der,
        #     subId=subId,
        #     numProc=numProc,
        #     simgMrtrix3=simgMrtrix3,
        #     simgANTs=simgANTs
        #     )
        
        # # each atlas save a matrix
        # for j in atlasPaths:
        #     logging.info(j)
        #     func_Connectome(
        #         codeTplPath=step3TplPath,
        #         projPath=proj,
        #         rawPath=os.path.split(i)[0],
        #         derPath=der,
        #         subId=subId,
        #         numProc=numProc,
        #         tplMNI152Atlas=j,
        #         tplMNI152AtlasLut=j.replace(".nii.gz", "_mrlut.txt"),
        #         tplMNI152AtlasPrefix=(j.split("_")[-2]).split("-")[-1],
        #         simgMrtrix3=simgMrtrix3,
        #         simgANTs=simgANTs
        #     )
        
        # save a fiber file for each roi
        for j in roiPaths:
            logging.info(j)
            func_Filtered(
                codeTplPath=step4TplPath,
                projPath=proj,
                rawPath=os.path.split(i)[0],
                derPath=der,
                subId=subId,
                numProc=numProc,
                roiPath=j,
                roiPrefix=(os.path.split(j)[-1]).replace(".nii.gz", "").replace("_", ""),
                simgMrtrix3=simgMrtrix3,
                simgANTs=simgANTs
                )        
        break