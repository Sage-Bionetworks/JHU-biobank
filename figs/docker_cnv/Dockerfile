################################################
# Dockerfile for GATK CNV analysis of WES data
################################################

# This image pulls in the gatk docker image on a linux base image and runs 10 different shell scripts on input bam files for CNV analysis of WES data. 
# Input files required: 1.sample_normal.bam, 2.sample_normal.bam.bai, 3.sample_tumor.bam, 4.sample_tumor.bam.bai
# Reference genome used: GRCh37.75
# Make directory with all required .bam and .bam.bai  files and pull this image from within the directory

#################################################

# Add GATK docker with all the tools required for analysis
FROM broadinstitute/gatk:latest

# File Author / Maintainer
MAINTAINER Jineta Banerjee <jineta.banerjee@sagebionetworks.org>

# Set up user
USER root

#Install synapse
RUN pip install synapseclient
#RUN synapse login

# Set the working directory to /data_dam
WORKDIR /root/data_bam/
# Copy the readme and datafiles into the container at /root/data_bam with instructions to put all data files here
COPY bin/data/README.txt /root/data_bam/

# Install package specific dependencies
#RUN pip install --upgrade pip
#RUN pip3 install wget 
#RUN pip3 install gcc.x86_64 
#RUN pip install bzip2
#RUN pip install ncurses-devel
#RUN pip install zlib-devel
#RUN pip install bzip2-devel
#RUN pip install xz-devel
#RUN wget https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
#RUN tar -vxjf /root/data_bam/samtools-1.9.tar.bz2
#WORKDIR /root/data_bam/samtools-1.9
#COPY bin/samtools-1.9/* /root/data_bam/samtools-1.9/
#RUN ./configure
#RUN make
#RUN make install
#RUN export PATH=/root/data_bam:$PATH

# Make working directory for scripts
WORKDIR /root/CNV_scripts

# Copy all shell scripts to the image
COPY bin/CNV_scripts/* /root/CNV_scripts/

# Make all scripts executable
RUN chmod a+x /root/CNV_scripts/1_bed_to_interval_list.sh
RUN chmod a+x /root/CNV_scripts/2_preprocess_intervals.sh
RUN chmod a+x /root/CNV_scripts/3_collect_reads.sh
#RUN chmod a+x /root/CNV_scripts/4_generate_PON.sh
RUN chmod a+x /root/CNV_scripts/5_denoise_read_counts.sh
RUN chmod a+x /root/CNV_scripts/6_plotdenoised_CR.sh
RUN chmod a+x /root/CNV_scripts/7_collect_allelic_counts.sh
RUN chmod a+x /root/CNV_scripts/8_modelsegments.sh
RUN chmod a+x /root/CNV_scripts/9_callcopyratio.sh
RUN chmod a+x /root/CNV_scripts/10_plot_modeled_copyratio.sh

WORKDIR  /root/data_bam/

#CMD ["/bin/bash"]
