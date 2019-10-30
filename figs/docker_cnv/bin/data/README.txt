##########################################################################################
#### This file describes requirements to run scripts for GATK CNV analysis on WES data ###
##########################################################################################

#### Step 1 ###

#Mount the data files into /data_bam/ folder using "-v" with docker run

#Required files for analysis:
#1. normal.bam
#2. normal.bam.bai
#3. tumor.bam
#4. tumor.bam.bai

# NOTE: if you do not have the .bam.bai files at hand, the docker provides samtools package that can be used to index the .bam files in situ

#### Step 2 ####

# Locate the relevant shell scripts in /CNV_scripts/ directory. The scripts are numbered in the order that they should be run. All output files will be generated in the /data_bam/ folder. For more in-depth information refer to https://gatkforums.broadinstitute.org/gatk/discussion/9143/how-to-call-somatic-copy-number-variants-using-gatk4-cnv/p1 

######  Step 3  ######

# Download the required reference files using the following commands into the terminal/command line interface:

#$ cd /root/data_bam/
#$ synapse -u "username" -p "password" get -r syn21075518
#$ gunzip *.gz
#$ tar -I lbzip2 -xvf *.bz2

# file provided include:
#1. Targets BED file
#2. Panel of normals file (pon)
#3. All reference genome files (.fa, .fai, .dict) for GRCh37.37
#4. samtools and picard tools for any file format conversions required

