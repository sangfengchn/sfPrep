'''
 # @ Author: feng
 # @ Create Time: 2023-02-28 08:42:17
 # @ Modified by: feng
 # @ Modified time: 2023-02-28 08:42:19
 # @ Description: Convert lut file to make it meet mrtirx3's format.
 '''

import os
from os.path import join as opj
import pandas as pd
from matplotlib import colors
import logging
logging.basicConfig(
    level=logging.INFO
)

if __name__ == "__main__":
    netName = "17Networks"
    parcelsName = "100Parcels"
    lutPath = f"resource/templateflow/tpl-MNI152NLin2009cAsym/tpl-MNI152NLin2009cAsym_atlas-Schaefer2018_desc-{parcelsName}{netName}_dseg.tsv"
    df = pd.read_csv(lutPath, sep="\t", index_col=0)
    newDf = pd.DataFrame()
    logging.info(df.head())
    # df["???"] = df["name"].str.replace("_", "")
    # logging.info(colors.to_rgb(df["color"].values[0]))
    
    for i in df.index.values:
        tmpColors = colors.to_rgb(df.loc[i, "color"])
        tmpName = df.loc[i, "name"]
        tmpDf = pd.DataFrame({"index": i, "???": tmpName.replace("_", ""), "Unknow": tmpName, "r": int(tmpColors[0] * 255), "g": int(tmpColors[1] * 255), "b": int(tmpColors[2] * 255), "a": 255}, index=["index"])
        newDf = pd.concat([newDf, tmpDf], ignore_index=True, axis=0)

    newDf.to_csv(lutPath.replace(".tsv", "_mrlut.txt"), sep="\t", index=False)