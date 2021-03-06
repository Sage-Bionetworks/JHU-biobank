#!/usr/bin/python

import sys
import os
import time
import re
import synapseclient
from synapseclient import File
import logging
log = logging.getLogger(__name__)
out_hdlr = logging.StreamHandler(sys.stdout)
out_hdlr.setFormatter(logging.Formatter('%(asctime)s %(message)s'))
out_hdlr.setLevel(logging.INFO)
log.addHandler(out_hdlr)
log.setLevel(logging.INFO)

syn = synapseclient.login()

tbl = syn.tableQuery("select * from syn17025501 where individualID is not null")
df = tbl.asDataFrame()

format = lambda x: x.replace(' ','_')
df['group'] = df['specimenID'].map(format)

grouped = df.groupby('group')
for name, group in grouped:
    file_list_f1 = []
    file_list_f2 = []
    for index,row in group.iterrows():
        temp = syn.get(row['id'],downloadLocation="./")
        file_path = row['name']
        os.rename(temp.path, file_path)
        while not os.path.exists(file_path):
            time.sleep(1)
        if re.search('_1.fastq.gz',file_path):
            file_list_f1.append(file_path)
        else:
            file_list_f2.append(file_path)
    # combine fastq files
    f1=os.path.join(name+'_1.fastq.gz')
    f2=os.path.join(name+'_2.fastq.gz')
    os.system("cat "+" ".join(file_list_f1)+" > "+f1)
    os.system("cat "+" ".join(file_list_f2)+" > "+f2)
    while not os.path.exists(f1) or not os.path.exists(f2):
        time.sleep(1)
    # remove fastq files
    for f in file_list_f1:
        os.remove(f)
    for f in file_list_f2:
        os.remove(f)
    # run salmon
    scmd='salmon quant -i gencode_v29_index -l A -1 '+f1+' -2 '+f2+' -o '+os.path.join("quants",name)
    log.debug(scmd)
    os.system(scmd)
    os.remove(f1)
    os.remove(f2)

# upload to Synpase
df.drop(columns=['id', 'name', 'dataFileHandleId'],inplace=True)
df.drop_duplicates(inplace=True)
df.reset_index(drop=True,inplace=True)
df['dataSubtype'] = 'processed'
df['fileFormat'] = 'sf'

format = lambda x: x.replace(' ','_')
df = df.fillna('')

for index,row in df.iterrows():
    folder_name = format(row['specimenID'])
    annotations = row.to_dict()
    temp = File(path=os.path.join("quants",folder_name,"quant.sf"), name="_".join([folder_name,"Salmon_gencodeV29","quant.sf"]), annotations=annotations,parent='syn17077846')
    temp = syn.store(temp)
    print(temp.id)