
library(reticulate)
synapse <- import("synapseclient")
syn <- synapse$Synapse()
syn$login()

require(tidyverse)
syn_file='syn18349249'
expData<-read.csv(gzfile(syn$get(syn_file)$path))%>%subset(study%in%c('JHU NTAP Biobank', 'Preclinical NF1-MPNST Platform Development'))

require(singleCellSeq)

#call the heatmap rmd
rmd<-system.file('heatmap_vis.Rmd',package='singleCellSeq')

this.code='https://raw.githubusercontent.com/Sage-Bionetworks/MPNSTAnalysis/master/analysis/NF_immune_sigs.R?token=ABwyOm38MhyuxTpTydIbnJDO1FnF12F1ks5cdXDFwA%3D%3D'
#rownames(expData)<-expData$id

#create matrix
combined.mat=reshape2::acast(expData,Symbol~id,value.var="zScore")
missing=which(apply(combined.mat,1,function(x) any(is.na(x))))
if(length(missing)>0)
  combined.mat=combined.mat[-missing,]

#create phenData
phenData<-expData%>%select(id,Sex,tumorType,isCellLine,study)%>%unique()
wd=getwd()

rownames(phenData)<-phenData$id
phenData$isCellLine<-tolower(phenData$isCellLine)
kf<-rmarkdown::render(rmd,rmarkdown::html_document(),output_file=paste(wd,'/',lubridate::today(),'immune_NFHeatmap.html',sep=''),params=list(samp.mat=combined.mat,cell.annotations=phenData%>%select(-id),seqData=TRUE))

analysis_dir='syn18086108'
syn$store(synapse$File(kf,parentId=analysis_dir),used=syn_file,executed=this.code)
