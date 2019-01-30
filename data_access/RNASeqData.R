library(tximport)
library(dplyr)
library(readr)

library(synapser)
#library(synapserutils)
synLogin()

options(stringsAsFactors = FALSE)

setwd(file.path(getwd(),"data_access"))
download.location <- "../temp/"

salmon.result.id <- "syn17077846" 
qc.id <- "syn17090810"
salmon.result <- synTableQuery("SELECT * FROM syn13363852 where dataSubtype = 'processed'")$asDataFrame()

### Remove 2-025_Neurofibroma due to high dup%
syn.query <- salmon.result[salmon.result$specimenID != "2-025 Neurofibroma",]

# download salmon result files from Synapse
downloadFiles <- function(syn.query, download.location){
  ddply(syn.query, .(id,name), function(x) {
  #  temp <- changeFileMetaData(x$id,downloadAs=x$name) #commented out after renaming
    temp <- synGet(x$id,downloadLocation=download.location)
  })
}

# testing
# library(tximportData)
# dir <- system.file("extdata", package = "tximportData")
# list.files(dir)
# tx2gene_v27 <- read_csv(file.path(dir, "tx2gene.gencode.v27.csv"))
#' prepare tx2gene data frame for tximport
prepareTx2gene <- function(annotation.file, format=c("gtf","gff3")){
  gtf <- rtracklayer::import(annotation.file, format=format)
  gtf_df <- as.data.frame(gtf@elementMetadata@listData)
  tx2gene <- gtf_df %>%
    select(transcript_id,gene_id) %>%
    na.omit() %>%
    distinct(transcript_id, gene_id, .keep_all = TRUE) %>%
    rename(TXNAME = transcript_id, GENEID = gene_id)
  return(tx2gene)  
}

#' load salmon result files and return tximport result
loadCountFiles <- function(syn.query, download.location, tx2gene, txOut = FALSE){
  files <- file.path(download.location, syn.query$name)
  names(files) <- syn.query$specimenID
  if(txOut){
    txi.tx <- tximport(files, type = "salmon", txOut = TRUE)
    txi <- summarizeToGene(txi.tx, tx2gene)
  }else{
    txi <- tximport(files, type = "salmon", tx2gene = tx2gene)
  }
  return(txi)
}

#' upload file to Synapse
upload2Synapse <- function(file.obj, download.location, folder.id, file.name, script.used){
  fname <- paste(download.location,file.name,sep="")
  write.table(file.obj,file=fname,sep='\t')
  sf <- File(fname,parentId=folder.id)
  synStore(sf,used=script.used)
}

#' build/load the count/tpm matrix
loadMatrix <- function(buildMatrix = FALSE, metric=c("counts","tpm"),
                       syn.query=syn.query, download.location=download.location, 
                       annotation.file='../temp/gencode.v29.annotation.gtf.gz', 
                       format="gtf", txOut = FALSE){
  if(buildMatrix){
    downloadFiles(syn.query,download.location)
    tx2gene <- prepareTx2gene(annotation.file,format=format)
    txi <- loadCountFiles(syn.query, download.location, tx2gene, txOut = txOut)
    
    if(metric=="counts"){
      result <- txi$counts
    }else if(metric=="tpm"){
      result <- txi$abundance
    }
    
    fname <- paste('salmonDerived',metric,'RNASeq_values_remove_highdup.tsv',sep='_')
    upload2Synapse(file.obj = result, 
                   download.location = download.location, 
                   folder.id = salmon.result.id, 
                   file.name = fname, 
                   script.used = 'https://raw.githubusercontent.com/Sage-Bionetworks/MPNSTAnalysis/master/data_access/RNASeqData.R')
  }else{
    if(metric=="counts"){
      temp <- as.matrix(data.table::fread(synGet("syn18103173")$path))
    }else if(metric=="tpm"){
      temp <- as.matrix(data.table::fread(synGet("syn18133883")$path))
    }
    result <- temp[,-1]
    rownames(result) <- temp[,1]
  }
  return(result)
}

# PCA plot
plotPCA<-function(count.mat,syn.query,
                  metric=c('counts','tpm'),ttype=c(),
                  xlim=0,ylim=0,scale=TRUE){
  require(ggbiplot)
  #samp.names <- colnames(count.mat)
  samp.indID <- as.character(syn.query$individualID)
  names(samp.indID) <- syn.query$specimenID
  
  zv<-which(apply(count.mat,1,var)==0)
  if(length(zv)>0)
    count.mat=count.mat[-zv,]

  if(length(ttype)>0.0){
    righttype=sapply(rownames(count.mat),function(x){
      gn=unlist(strsplit(x,split='.',fixed=T))
      gn[length(gn)]%in%ttype})
    count.mat=count.mat[which(righttype),]
  }
  pn <- prcomp(t(count.mat),center=T,scale=scale)
  png(paste(metric,'valuesin',paste(ttype,collapse='_'),'RNASeqData.png',sep=''))
  p <- ggbiplot(pn,groups=samp.indID,var.axes=F)
  #p <- p + geom_text(aes(label=ifelse(PC1<xlim,as.character(samp.indID),'')),hjust=0,vjust=0)
  print(p)
  dev.off()
}

#######################################
# Manual testing; keep high dup% sample
#######################################
# downloadFiles(salmon.result,download.location)
# tx2gene <- prepareTx2gene('../temp/gencode.v29.annotation.gtf.gz', format="gtf")
txi.all <- loadCountFiles(salmon.result,download.location,tx2gene)
# txi.sum <- loadCountFiles(salmon.result,download.location,tx2gene,txOut = TRUE)
# all.equal(txi.all$counts, txi.sum$counts)
# 
# # Upload to Synapse
# metric <- "counts"
# fname <- paste('salmonDerived',metric,'RNASeq_values.tsv',sep='_')
# upload2Synapse(file.obj = txi.all$counts, 
#                download.location = download.location, 
#                folder.id = salmon.result.id, 
#                file.name = fname, 
#                script.used = 'https://raw.githubusercontent.com/Sage-Bionetworks/MPNSTAnalysis/master/data_access/RNASeqData.R')
# 
# metric <- "tpm"
# fname <- paste('salmonDerived',metric,'RNASeq_values.tsv',sep='_')
# upload2Synapse(file.obj = txi.all$abundance, 
#                download.location = download.location, 
#                folder.id = salmon.result.id, 
#                file.name = fname, 
#                script.used = 'https://raw.githubusercontent.com/Sage-Bionetworks/MPNSTAnalysis/master/data_access/RNASeqData.R')
#
# plotPCA(log2(txi.all$counts+1),salmon.result,metric = "counts")
# sf <- File("./countsvaluesinRNASeqData.png",parentId=qc.id)
# synStore(sf,used="https://raw.githubusercontent.com/Sage-Bionetworks/MPNSTAnalysis/master/data_access/RNASeqData.R")
  
  
