#!/usr/bin/python

import sys
import os
import time
import re
import synapseclient
from synapseclient import File

syn = synapseclient.login()

tbl = syn.tableQuery("select * from syn17038362 where individualID is not null")
df = tbl.asDataFrame()

grouped = df.groupby('specimenID')

for name, group in grouped:
    os.system("mkdir "+ os.path.join("quality_control",name))
    for index,row in group.iterrows():
        temp = syn.get(row['id'],downloadLocation="./")
        file_path = name+"_"+row['name']
        os.rename(temp.path, file_path)
        while not os.path.exists(file_path):
            time.sleep(1)
        scmd='~/FastQC/fastqc -o ' + os.path.join("quality_control",name) + ' ' + file_path
        os.system(scmd)
        os.remove(file_path)
