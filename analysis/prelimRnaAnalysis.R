library(pheatmap)
library(ggbiplot)

# copied from pNF repo; needs to be modified
plotPCA<-function(count.mat,metric='tpm'){
  samp.names=samp.mappings$sampleIdentifier[match(colnames(count.mat),samp.mappings$rnaSeq)]
  samp.gen=samp.mappings$nf1Genotype[match(colnames(count.mat),samp.mappings$rnaSeq)]
  names(samp.gen)<-samp.names
  colnames(count.mat)<-samp.names
  
  zv<-which(apply(count.mat,1,var)==0)
  if(length(zv)>0)
    count.mat=count.mat[-zv,]
  pn<-prcomp(t(count.mat),center=T,scale=T)
  png(paste(metric,'valuesinRNASeqData.png',sep=''))
  p<-ggbiplot(pn,groups=samp.gen,var.axes=F)
  print(p)
  dev.off()
  
}

##plot PCA
plotPCA(log2(tpm+0.01),'tpm')
plotPCA(log2(counts+1),'est_counts')