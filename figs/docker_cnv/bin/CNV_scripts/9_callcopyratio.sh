#!usr/bin/bash
for file in /root/data_bam/*.bam
do
        #echo ${file}
        export id=$(basename ${file})
        export filename=$(echo ${id} | tr ".bam" "")
        #echo ${filename}
	gatk CallCopyRatioSegments \
   		 --input /root/data_bam/${filename}.cr.seg \
   		 --output /root/data_bam/${filename}.called.seg
done
