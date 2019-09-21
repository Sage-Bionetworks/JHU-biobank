require(synapser)
synLogin()
require(tidyverse)

tab<-read.csv(synGet('syn18635308')$path)%>%rename(specimenID='sample.name')


#get clinical data
clin.dat<-synTableQuery("SELECT distinct specimenID,individualID,diagnosis,tumorType,isCellLine,tissue FROM syn13363852 WHERE ( (\"assay\" = 'exomeSeq' ) AND ( \"resourceType\" = 'analysis' ) )")$asDataFrame()

full.tab<-tab%>%left_join(clin.dat,by='specimenID')
ggplot(subset(full.tab,copy.count!=2))+geom_jitter(aes(x=seqnames,y=copy.count,col=tumorType))
