<p align="center">
</p>

# JHU Biobank Code Repository

This repository contains the information about the RNA-seq processing and figure generation for the Scientific Data Biobank Manuscript.

## Prerequisites
These instructions assume that you:
* have registered for a [Synapse account](https://www.synapse.org/#!RegisterAccount:0)
* have followed the [Getting Samples and Data](https://www.synapse.org/#!Synapse:syn4939902/wiki/593715) instructions on Synapse.
* have [installed Docker Community Edition](https://docs.docker.com/v17.12/install/) and that the docker service is running on your machine
* are running a Unix-based OS, such as Ubuntu or Mac. These instructions have not been tested on Windows-based platforms. If you are using Google Cloud Platform, please see the [Google Cloud Docker instructions](#google-cloud).

## Samples available
We are constantly updating the data available. To find an up-to-date list please log into the Synapse site and click [this link](https://www.synapse.org/#!Synapse:syn13363852/tables/query/eyJzcWwiOiJTRUxFQ1QgZGlzdGluY3QgaW5kaXZpZHVhbElELHNwZWNpbWVuSUQsYXNzYXkgRlJPTSBzeW4xMzM2Mzg1MiB3aGVyZSBhY2Nlc3NUeXBlIDw+ICdQUklWQVRFJyIsICJpbmNsdWRlRW50aXR5RXRhZyI6dHJ1ZSwgImlzQ29uc2lzdGVudCI6dHJ1ZSwgIm9mZnNldCI6MCwgImxpbWl0IjoyNX0=)


## RNA-Seq and Exome-seq processing

The RNA-seq and Exome-Seq data is available in tabular form on the [JHU Biobank Synapse Site](http://synapse.org/jhubiobank)
* [RNA-Seq Counts](https://www.synapse.org/#!Synapse:syn20812185/tables/)
* [Germline variant calls](https://www.synapse.org/#!Synapse:syn20812188/tables/)

These were processed by independent pipelines that can be found in the [Sage Bionetworks Rare Disease Workflows](https://github.com/sage-bionetworks/rare-disease-workflows) repository. 

Specifically the YAML file input for the RNA-Seq data is as follows:
```
synapse_config:
  class: File
  path: "/home/sgosline/.synapseConfig"
indexid: syn18134565
index-type: gencode
index-dir: gencode_v29
idquery: SELECT specimenID,id,readPair FROM syn13363852 WHERE ( ( "assay" = 'rnaSeq' ) AND ( "fileFormat" = 'fastq' ) AND ( "sciDataRelease" = 'true' ) ) order by specimenID
sample_query: SELECT distinct specimenID,individualID,assay,dataType,sex,consortium,study,diagnosis,tumorType,species,fundingAgency,resourceType,nf1Genotype,nf2Genotype,studyName FROM syn13363852 WHERE ( ( "assay" = 'rnaSeq' ) AND ( "fileFormat" = 'fastq' ) AND ( "sciDataRelease" = 'true' ) )
parentid: syn17077846
group_by: specimenID
tableparentid: 
        - syn4939902
tablename: 
        - Biobank RNASeq Data
```

The YAML file for the Exome seq harmonization is below:
```
vep-file-id: syn18491780
synapse_config:
  class: File
  path: /Users/rallaway/.synapseConfig
parentid: syn20540114
group_by: mafid
input-query: SELECT id FROM syn11818313 WHERE ( ( "fileFormat" = 'vcf' ) AND ( "isMultiSpecimen" = 'FALSE' ) AND ( "assay" = 'exomeSeq' ) ) 
clinical-query: SELECT distinct id as mafid,specimenID,individualID,assay,dataType,sex,consortium,diagnosis,tumorType,species,fundingAgency,resourceType,nf1Genotype,nf2Genotype,studyName from syn11818313
indexfile:
  class: File
  path: index.fa
```
  

## RNA-seq and Exome-Seq figures

The code to generate the omics figures in the manuscript can be found in the [figs](figs/) directory. Specifically the ExomeSeq markdown can be viewed [here]() and the RNASeq markdown can be viewed [here](). 

## Demonstration notebooks

We've prepared Docker containers that contain all of the necessary dependencies to retrieve data from Synapse and perform some basic analyses of these data. The goal of this is to help you orient yourself to the data prior to the event in September.
We've created containers for both R and Python users. You can find instructions on running these containers and following the data demos below.
If you like, you can also use these containers as a basis for creating your own Docker containers during the hackathon so that others can reproduce your analyses.


### RStudio Docker Image (Local)

1. Open a command line interface, such as Terminal.
2. Do `docker pull nfosi/jhu-biobank-r` to get the Docker image.
3. Do `docker run -e PASSWORD=<mypassword> -e ROOT=true --rm -p 8787:8787 nfosi/jhu-biobank-r` to start the container. Make sure to replace `<mypassword>` with a unique password. It cannot be "rstudio"!
4. Open your preferred browser and navigate to `localhost:8787`. Login using the username "rstudio" and the password that you set in step 3.
5. In the Files pane, click on "0-setup.Rmd" to get started, and to learn how to make your Synapse credentials available to `synapser`.

*IMPORTANT NOTE* To save any results created during your Docker session, you'll need to mount a local directory to the Docker container when you run it. This will copy anything saved to the working directory to your local machine. Before step 4, do `mkdir output` to create an output directory locally. Then run the command in step 4 with a `-v` flag e.g. `docker run -e PASSWORD=pwd --rm -p 8787:8787 -v $PWD/output:/home/rstudio/output nfosi/jhu-biobank-r` Alternatively, or in addition, you can save all of your results to Synapse using `synapser`.

### jupyter Docker Image (Local)

1. Open a command line interface, such as Terminal.
2. Do `docker pull nfosi/jhu-biobank-py` to get the Docker image.
3. Do `docker run -p 8888:8888 nfosi/nfosi/jhu-biobank-py` to start the container.
4. Open your preferred browser and navigate to the one of the links provided in your Terminal window after running the previous command. It should look something like: `http://127.0.0.1:8888/?token=abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234`.
5. In the Files pane, click on "Work" and then "0-setup.ipynb" to get started, and to learn how to make your Synapse credentials available to the Python `synapseclient`.

*IMPORTANT NOTE* To save any results created during your Docker session, you'll need to mount a local directory to the Docker container when you run it. This will copy anything saved to the working directory to your local machine. Before step 4, do `mkdir output` to create an output directory locally. Then run the command in step 4 with a `-v` flag e.g. `docker run -p 8888:8888 -v $PWD/output:/home/jovyan/work/output nfosi/jhu-biobank-py
` Alternatively, or in addition, you can save all of your results to Synapse using `synapseclient`.



### CNV Analysis Docker Image (Local)

The somatic copy number variation (CNV) analysis was done on WES files using a series of shell scripts generating plots of CNV as output. The series of shell scripts with the relevant reference files have been dockerized for reproducibility of the plots. The analysis can be reproduced by following the steps outlined below.

1. Open a command line interface, such as Terminal.
2. Do `docker pull jinetabanerjee/jhu_cnv_analysis:latest` to get the Docker image.
3. Do `docker run -ti jinetabanerjee/jhu_cnv_analysis:latest bash` to start the container. 
4. Follow the README.txt in the data_bam folder in the docker container to carry out the relevant analysis.

*IMPORTANT NOTE* To save any results created during your Docker session, you'll need to mount a local directory to the Docker container when you run it. This will copy anything saved to the working directory to your local machine. Before step 3, do `mkdir data_bam` to create an input/output directory locally and store all the relevant .bam and .bam.bai files in there. Then run the command in step 3 with a `-v` flag e.g. `docker run -ti -v $PWD/data_bam:/root/data_bam/ jinetabanerjee/jhu_cnv_analysis:latest`.
