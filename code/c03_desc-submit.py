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

def func_Preprocessing(codeTplPath, projPath, rawPath, derPath, subId, numProc, tplPath, tplT1wPath, tplBrainPath, tplBrainMaskPath, simgPath):
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
    codeStr = [re.sub("#SIMG#", simgPath, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)
    
def func_Tractography(codeTplPath, projPath, rawPath, derPath, subId, numProc,  simgPath):
    with open(codeTplPath, "r") as f:
        codeStr = f.readlines()
    codeStr = [re.sub("#PROJ#", projPath, i) for i in codeStr]
    codeStr = [re.sub("#RAW#", rawPath, i) for i in codeStr]
    codeStr = [re.sub("#DER#", derPath, i) for i in codeStr]
    codeStr = [re.sub("#SUBID#", subId, i) for i in codeStr]
    codeStr = [re.sub("#NUMPROC#", str(numProc), i) for i in codeStr]
    codeStr = [re.sub("#SIMG#", simgPath, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)
    
def func_Connectome(codeTplPath, projPath, rawPath, derPath, subId, numProc, tplMNI152Atlas, tplMNI152AtlasLut, tplMNI152AtlasPrefix, simgPath):
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
    codeStr = [re.sub("#SIMG#", simgPath, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)

def func_Filtered(codeTplPath, projPath, rawPath, derPath, subId, numProc, roiPath, roiPrefix, simgPath):
    with open(codeTplPath, "r") as f:
        codeStr = f.readlines()
    codeStr = [re.sub("#PROJ#", projPath, i) for i in codeStr]
    codeStr = [re.sub("#RAW#", rawPath, i) for i in codeStr]
    codeStr = [re.sub("#DER#", derPath, i) for i in codeStr]
    codeStr = [re.sub("#SUBID#", subId, i) for i in codeStr]
    codeStr = [re.sub("#NUMPROC#", str(numProc), i) for i in codeStr]
    codeStr = [re.sub("#ROIPATH#", roiPath, i) for i in codeStr]
    codeStr = [re.sub("#ROIPREFIX#", roiPrefix, i) for i in codeStr]
    codeStr = [re.sub("#SIMG#", simgPath, i) for i in codeStr]
    codeStr = [re.sub("\"", "\\\"", i) for i in codeStr]
    codeStr = "".join(codeStr)
    # logging.info(codeStr)
    try:
        p = subprocess.run("bash", input=codeStr, encoding="utf-8", shell=True, check=True, stdout=subprocess.PIPE)
        logging.info(p.stdout)
    except subprocess.CalledProcessError as err:
        logging.error("Error: ", err)


if __name__ == "__main__":
    proj = "/home/feng/Projects/L_desc-qsiprep"
    raw = opj(proj, "rawdata")
    der = opj(proj, "derivatives", "sfprep")
    numProc = 10
    
    tplPath = opj(proj, "resource", "templateflow", "tpl-MNI152NLin2009cAsym")
    tplT1wPath = opj(tplPath, "tpl-MNI152NLin2009cAsym_res-01_T1w.nii.gz")
    tplBrainPath = opj(tplPath, "tpl-MNI152NLin2009cAsym_res-01_desc-brain_T1w.nii.gz")
    tplBrainMaskPath = opj(tplPath, "tpl-MNI152NLin2009cAsym_res-01_desc-brain_mask.nii.gz")
    
    simgPath = opj(proj, "..", "..", "Envs", "qsiprep-0.16.1")
    
    step1TplPath = opj(proj, "code", "c03_desc-1preprocess_template.sh")
    step2TplPath = opj(proj, "code", "c03_desc-2tractography_template.sh")
    step3TplPath = opj(proj, "code", "c03_desc-3connectome_template.sh")
    step4TplPath = opj(proj, "code", "c03_desc-4filtered_template.sh")
    
    atlasPaths = glob(opj(proj, "resource", "templateflow", "tpl-MNI152NLin2009cAsym", "*_dseg.nii.gz"))
    roiPaths = glob(opj(proj, "resource", "RegionsOfInteresting", "*.nii.gz"))
    
    for i in glob(opj(raw, "sub-*")):
        subId = os.path.split(i)[-1]
        logging.info(subId)
        
        func_Preprocessing(
            codeTplPath=step1TplPath,
            projPath=proj,
            rawPath=os.path.split(i)[0],
            derPath=der,
            subId=subId,
            numProc=numProc,
            tplPath=tplPath,
            tplT1wPath=tplT1wPath,
            tplBrainPath=tplBrainPath,
            tplBrainMaskPath=tplBrainMaskPath,
            simgPath=simgPath
            )
        
        func_Tractography(
            codeTplPath=step2TplPath,
            projPath=proj,
            rawPath=os.path.split(i)[0],
            derPath=der,
            subId=subId,
            numProc=numProc,
            simgPath=simgPath
            )
        
        for j in atlasPaths:
            logging.info(j)
            func_Connectome(
                codeTplPath=step3TplPath,
                projPath=proj,
                rawPath=os.path.split(i)[0],
                derPath=der,
                subId=subId,
                numProc=numProc,
                tplMNI152Atlas=j,
                tplMNI152AtlasLut=j.replace(".nii.gz", "_mrlut.txt"),
                tplMNI152AtlasPrefix=(j.split("_")[-2]).split("-")[-1],
                simgPath=simgPath
            )
        
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
                simgPath=simgPath
                )        
        break