#!/bin/bash
#loop through all file in the folder and do collect Fragments on each file
for file in /root/data_bam/*.bam
do
	#echo ${file}
	export id=$(basename ${file})
	export filename=$(echo ${id} | tr ".bam" "-f")
	#echo ${filename}
	gatk CollectReadCounts \
	       	-I ${file} \
		-L /root/data_bam/Targets_experimental_0bin.preprocessed.interval_list \
		--interval-merging-rule OVERLAPPING_ONLY \
		-O /root/data_bam/${filename}.counts.hdf5
done

