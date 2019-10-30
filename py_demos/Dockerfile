##Start from base jupyter notebook docker container
FROM jupyter/base-notebook:6c3390a9292e

##jupyter does not have root user as default, so switch to root to use apt-get and pip3
USER root 

RUN apt-get update
RUN apt-get -y install gcc

#upgrade pip and get synapseclient
RUN pip install --upgrade pip
RUN pip install synapseclient numpy pandas matplotlib sklearn dfply bokeh seaborn
RUN mkdir /home/jovyan/work/output

COPY 0-setup.ipynb /home/jovyan/work/0-setup.ipynb
COPY 1-rnaseq-intro.ipynb /home/jovyan/work/1-rnaseq-intro.ipynb
COPY 2-exomeseq-intro.ipynb /home/jovyan/work/2-exomeseq-intro.ipynb
