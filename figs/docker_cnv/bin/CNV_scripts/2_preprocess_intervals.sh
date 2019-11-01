gatk PreprocessIntervals \
	-L /root/data_bam/Targets.interval_list \
	-R /root/data_bam/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa \
	--bin-length 0 \
	--interval-merging-rule OVERLAPPING_ONLY \
	-O /root/data_bam/Targets_experimental_0bin.preprocessed.interval_list
