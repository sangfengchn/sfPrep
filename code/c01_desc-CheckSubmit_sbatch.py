'''
 # @ Author: feng
 # @ Create Time: 2023-04-30 11:14:35
 # @ Modified by: feng
 # @ Modified time: 2023-04-30 11:14:37
 # @ Description: Check results of running.
 '''

import os
from os.path import join as opj
from os.path import exists as ope
from glob import glob
import shutil
import logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(message)s")

der = "derivatives/sfprep"
for i in glob(opj(der, "sub-*")):
    subId = os.path.split(i)[-1]
    if ope(opj(i, "log", "finished")): continue
    if ope(opj(i, "net")) and ope(opj(i, "fibs")): shutil.rmtree(opj(i, "fibs"))

logging.info("Done.")