'''
 # @ Author: feng
 # @ Create Time: 2023-05-09 14:10:57
 # @ Modified by: feng
 # @ Modified time: 2023-05-09 14:10:58
 # @ Description: Copy the finished results automaticly.
 '''

import os
from os.path import join as opj
from glob import glob
import time
import shutil
import logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

proj = "."
der = opj(proj, "derivatives", "sfprep")
out = opj(proj, "NeedToDownload")
# if not os.path.exists(out): os.makedirs(out)

while True:
    for i in glob(opj(der, "sub-*")):
        # finished 
        if (os.path.exists(opj(i, "log", "finished")) and 
            (not os.path.exists(opj(i, "log", "copied")))):
            tmpSubId = os.path.split(i)[-1]
            logging.info(f"Copying {tmpSubId}...")
            tmpSrcPath = i
            tmpDstPath = opj(out, tmpSubId)
            shutil.move(tmpSrcPath, tmpDstPath)
            # create a flag for preprocessing, and avoid to preproce again for same subject.
            os.makedirs(opj(i, "log"))
            with open(opj(i, "log", "copied"), "w") as f: f.writelines("")
            
    # take an hour off after searching once
    logging.info("Sleeping...")
    time.sleep(1*60*60)

# some bugs because don't considering carefully.
# for i in glob(opj(out, "sub-*")):
#     subId = os.path.split(i)[-1]
#     if not os.path.exists(opj(der, subId, "log")): os.makedirs(opj(der, subId, "log"))
#     with open(opj(der, subId, "log", "copied"), "w") as f: f.writelines("")


logging.info("Copy finished.")