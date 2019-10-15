#!/usr/bin/python

import sys
import os
import time
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

tbl = syn.tableQuery("select * from syn17038362 where individualID is not null")
df = tbl.asDataFrame()

grouped = df.groupby('specimenID')
for name, group in grouped:
    file_list_f1 = []
    file_list_f2 = []
    for index,row in group.iterrows():
        temp = syn.get(row['id'],downloadLocation="./")
        file_path = row['name']
        while not os.path.exists(file_path):
            time.sleep(1)
        base = os.path.basename(file_path)
        file_name = os.path.splitext(base)[0]
        sorted_file = file_name+"_sorted.bam"
        temp_f1=os.path.join(file_name+'_1.fastq')
        temp_f2=os.path.join(file_name+'_2.fastq')
        # sort bam file
        sortcmd = 'samtools sort -n '+file_path+' -o '+ sorted_file
        log.debug(sortcmd)
        os.system(sortcmd)
        while not os.path.exists(sorted_file):
            time.sleep(1)
        # bam2fastq - pairend
        bedcmd='bedtools bamtofastq -i '+sorted_file+' -fq '+temp_f1+' -fq2 '+temp_f2
        log.debug(bedcmd)
        os.system(bedcmd)
        while not os.path.exists(temp_f1) or not os.path.exists(temp_f2):
            time.sleep(1)
        file_list_f1.append(temp_f1)
        file_list_f2.append(temp_f2)
        os.remove(file_path)
        os.remove(sorted_file)
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
    # alignment
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
df = df.fillna('')

for index,row in df.iterrows():
    folder_name = row['specimenID']
    annotations = row.to_dict()
    temp = File(path=os.path.join("quants",folder_name,"quant.sf"), name="_".join([folder_name,"Salmon_gencodeV29","quant.sf"]), annotations=annotations,parent='syn17077846')
    temp = syn.store(temp)
    print(temp.id)