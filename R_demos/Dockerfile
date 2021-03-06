## Start from this Docker image
FROM rocker/tidyverse
## use rocker as a base image

## install synapser reqs
RUN apt-get update -y
RUN apt-get install -y dpkg-dev zlib1g-dev libssl-dev libffi-dev
RUN apt-get install -y curl libcurl4-openssl-dev

## install synapser
RUN R -e "install.packages('synapser', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"
RUN R -e "install.packages('synapserutils', repos=c('http://ran.synapse.org', 'http://cran.fhcrc.org'))"


## install bioconductor packages
RUN R -e "install.packages('BiocManager')"
RUN R -e "BiocManager::install(c('GSVA', 'GSEABase', 'org.Hs.eg.db', 'limma', 'GOsummaries', 'GSVAdata', 'biomaRt', 'maftools', 'Biostrings'))"

## install cran packages
RUN R -e "install.packages(c('biomartr','gProfileR', 'umap', 'dbscan', 'ggfortify', 'pheatmap', 'ggpubr', 'DT', 'here', 'reshape2', 'RColorBrewer', 'wesanderson'))"

RUN mkdir /home/rstudio/output

COPY 0-setup.Rmd /home/rstudio/0-setup.Rmd 
COPY 1-rnaseq-data-introduction.Rmd /home/rstudio/1-rnaseq-data-introduction.Rmd
COPY 2-exomeseq-introduction.Rmd /home/rstudio/2-exomeseq-introduction.Rmd

RUN "wget https://raw.githubusercontent.com/Sage-Bionetworks/JHU-biobank/master/figs/Scidata2019_figs_genomicVariants.Rmd"
RUN "wget https://raw.githubusercontent.com/Sage-Bionetworks/JHU-biobank/master/figs/SciData2019_RNASeqFigs.Rmd"
RUN "mv Scidata2019_figs_genomicVariants.Rmd /home/rstudio/Scidata2019_figs_genomicVariants.Rmd"
RUN "mv SciData2019_RNASeqFigs.Rmd /home/rstudio/SciData2019_RNASeqFigs.Rmd"
