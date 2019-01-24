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
salmon.result <- synTableQuery("SELECT * FROM syn13363852 where dataSubtype = 'processed'")$asDataFrame()

downloadFiles <- function(syn.query, download.location){
  ddply(syn.query, .(id,name), function(x) {
  #  temp <- changeFileMetaData(x$id,downloadAs=x$name) #commented out after renaming
    temp <- synGet(x$id,downloadLocation=download.location)
  })
}

# library(tximportData)
# dir <- system.file("extdata", package = "tximportData")
# list.files(dir)
# tx2gene_v27 <- read_csv(file.path(dir, "tx2gene.gencode.v27.csv"))
prepareTx2gene <- function(annotation.file, format=c("gtf","gff3")){
  gtf <- rtracklayer::import(annotation.file, format=format)
  gtf_df <- as.data.frame(gtf@elementMetadata@listData)
  tx2gene <- gtf_df %>%
    select(transcript_id,gene_id) %>%
    na.omit() %>%
    distinct(transcript_id, gene_id, .keep_all = TRUE)
  rename(TXNAME = transcript_id, GENEID = gene_id)
  return(tx2gene)  
}

loadCountFiles <- function(syn.query, download.location, tx2gene){
  files <- file.path(download.location, syn.query$name)
  names(files) <- syn.query$specimenID
  txi <- tximport(files, type = "salmon", tx2gene = tx2gene)
  return(txi)
}

# downloadFiles(salmon.result,download.location)
# tx2gene <- prepareTx2gene('../temp/gencode.v29.annotation.gtf.gz', format="gtf")
count.list <- loadCountFiles(salmon.result,download.location,tx2gene)




