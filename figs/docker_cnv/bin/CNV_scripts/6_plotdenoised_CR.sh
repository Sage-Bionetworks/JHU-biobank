for file in /root/data_bam/*.bam
do
        #echo ${file}
        export id=$(basename ${file})
        export filename=$(echo ${id} | tr ".bam" "")
        #echo ${filename}
	gatk PlotDenoisedCopyRatios \
   		 --standardized-copy-ratios /root/data_bam/${filename}.standardizedCR.tsv \
    		 --denoised-copy-ratios /root/data_bam/${filename}.denoisedCR.tsv \
   		 --sequence-dictionary /root/data_bam/Homo_sapiens.GRCh37.75.dna.primary_assembly.dict \
   		 --minimum-contig-length 46709983 \
   		 --output /root/data_bam/plots \
   		 --output-prefix ${filename}
done
