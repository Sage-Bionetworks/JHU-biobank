#!/usr/bin/python

import sys
import os
import time
import re
import synapseclient

syn = synapseclient.login()

# fastq
tbl = syn.tableQuery("select * from syn17025501 where individualID is not null")
df = tbl.asDataFrame()

format = lambda x: x.replace(' ','_')
df['group'] = df['specimenID'].map(format)

grouped = df.groupby('specimenID')

for name, group in grouped:
    os.system("mkdir "+name)
    for index,row in group.iterrows():
        temp = syn.get(row['id'],downloadLocation="./")
        file_path = row['name']
        os.rename(temp.path, file_path)
        while not os.path.exists(file_path):
            time.sleep(1)
        qcmd = "~/FastQC/fastqc -o "+name+" "+file_path
        os.system(qcmd)
        os.remove(file_path)

# bam
tbl = syn.tableQuery("select * from syn17038362 where individualID is not null")
df = tbl.asDataFrame()

format = lambda x: x.replace(' ','_')
df['group'] = df['specimenID'].map(format)

grouped = df.groupby('specimenID')

for name, group in grouped:
    os.system("mkdir "+name)
    for index,row in group.iterrows():
        temp = syn.get(row['id'],downloadLocation="./")
        file_path = row['name']
        os.rename(temp.path, file_path)
        while not os.path.exists(file_path):
            time.sleep(1)
        qcmd = "~/FastQC/fastqc -o "+name+" "+file_path
        os.system(qcmd)
        os.remove(file_path)
