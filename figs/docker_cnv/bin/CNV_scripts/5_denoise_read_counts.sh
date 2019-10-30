for file in /root/data_bam/*.counts.hdf5
do
        #echo ${file}
        export id=$(basename ${file})
        export filename=$(echo ${id} | tr ".counts.hdf5" "")
        #echo ${filename}
	gatk --java-options "-Xmx12g" DenoiseReadCounts \
    		-I ${file} \
    		--count-panel-of-normals /root/data_bam/CNV_pon_experimentalnormals.pon.hdf5 \
    		--standardized-copy-ratios /root/data_bam/${filename}.standardizedCR.tsv \
    		--denoised-copy-ratios /root/data_bam/${filename}.denoisedCR.tsv
done

