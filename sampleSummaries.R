#create sample summaries from releavant metadata tables
library(synapser)
synLogin()

require(tidyverse)

biobankTable='syn13363852'
washUTable='syn11678418'

patientSamplesByData<-function(fvId,title='',reportingFolder=''){
  #get data and format
  tab<-do.call('rbind',lapply(fvId,function(x){
    synTableQuery(paste('select distinct individualID,sex,specimenID,tumorType from',x,'WHERE isMultiSpecimen is FALSE'))$asDataFrame()}))
  
  ntab<-tab%>%group_by(individualID,tumorType)%>%summarize(Specimens=n_distinct(specimenID))
  
  #then plot
  require(ggplot2)
  ggplot(ntab)+geom_bar(aes(x=individualID,y=Specimens,fill=tumorType),stat='identity',position='dodge')+ theme(axis.text.x = element_text(angle = 90, hjust = 1))+ggtitle(title)
  fname=paste(gsub(' ','',title),'sampleSummary.png',sep='')
  ggsave(file=fname)
  synStore(File(fname,parentId=reportingFolder),used=fvId)
  
}

#original biobank
patientSamplesByData(biobankTable,'JHU Biobank Samples',reportingFolder='syn16847927')

#hirbe data
patientSamplesByData(washUTable,'WashU Biobank Samples',reportingFolder='syn14780439')

#both datasets
patientSamplesByData(c(biobankTable,washUTable),'All Biobank Samples',reportingFolder='syn16847927')
