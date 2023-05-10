'''
 # @ Author: feng
 # @ Create Time: 2023-05-10 13:58:35
 # @ Modified by: feng
 # @ Modified time: 2023-05-10 13:59:05
 # @ Description: Remove subject's derivative folder.
 '''

import os
from os.path import join as opj
import shutil
from glob import glob
import logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

proj = "."
der = opj(proj, "derivatives", "sfprep")

for i in glob(opj(der, "sub-*")):
    if os.path.exists(opj(i, "log", "copied")): continue
    if os.path.exists(opj(i, "dwi", "streamlines.tck")):
        logging.info(i)
        # shutil.rmtree(i)
        
logging.info("Done.")