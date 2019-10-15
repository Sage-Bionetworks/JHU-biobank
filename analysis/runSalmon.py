#!/usr/bin/python

import sys
import os
import subprocess
import synapseclient
import logging
log = logging.getLogger(__name__)
out_hdlr = logging.StreamHandler(sys.stdout)
out_hdlr.setFormatter(logging.Formatter('%(asctime)s %(message)s'))
out_hdlr.setLevel(logging.INFO)
log.addHandler(out_hdlr)
log.setLevel(logging.INFO)

syn = synapseclient.login()

tbl = syn.tableQuery("select id, name from syn17025501 where individualID is not null")
df = tbl.asDataFrame()

format = lambda x: "_".join(x.split("_")[0:3])
df['group'] = df['name'].map(format)

grouped = df.groupby('group')
for name, group in grouped:
    if(len(group.index) < 2):
        log.error(name)
    else:
        for id in group['id'].tolist():
            p1 = subprocess.Popen(("synapse get " + id))
            p1.wait()
        f1=os.path.join(name+'_1.fastq.gz')
        f2=os.path.join(name+'_2.fastq.gz')
        scmd='salmon quant -i gencode_v29_index -l A -1 '+f1+' -2 '+f2+' -o '+os.path.join("quants",name)
        log.debug(scmd)
        p2 = subprocess.Popen((scmd))
        p2.wait()