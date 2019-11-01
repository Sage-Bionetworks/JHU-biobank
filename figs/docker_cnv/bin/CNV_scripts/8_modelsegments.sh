#!usr/bin/bash
for file in /root/data_bam/*.bam
do
        #echo ${file}
        export id=$(basename ${file})
        export filename=$(echo ${id} | tr ".bam" "")
        #echo ${filename}
	gatk --java-options "-Xmx100g" ModelSegments \
   		 --denoised-copy-ratios /root/data_bam/${filename}.denoisedCR.tsv \
   		 --allelic-counts /root/data_bam/${filename}.allelicCounts.tsv \
   		 --normal-allelic-counts /root/data_bam/normal.allelicCounts.tsv \
   		 --output /root/data_bam/ \
   		 --output-prefix ${filename}
done

