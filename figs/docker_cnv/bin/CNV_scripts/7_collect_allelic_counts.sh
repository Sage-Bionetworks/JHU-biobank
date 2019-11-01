#!usr/bin/bash
for file in /root/data_bam/*.bam
do
        #echo ${file}
        export id=$(basename ${file})
        export filename=$(echo ${id} | tr ".bam" "")
        #echo ${filename}
	gatk --java-options "-Xmx10g" CollectAllelicCounts \
   		 -L /root/data_bam/Targets_experimental_0bin.preprocessed.interval_list \
   		 -I ${file} \
   		 -R /root/data_bam/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
   		 -O /root/data_bam/${filename}.allelicCounts.tsv
done
