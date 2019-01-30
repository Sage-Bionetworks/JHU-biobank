source("../data_access/RNASeqData.R")

library(DESeq2)

setwd(file.path(getwd(),"analysis"))

## constract DESeq data set
metadata.df <- syn.query[,colSums(is.na(syn.query))<nrow(syn.query)]
cols.keep <- c("specimenID","id","individualID","sex","tumorType","isCellLine","isPrimaryCell","tissue",
               "experimentalCondition","consortium","study")
metadata.df <- metadata.df[,cols.keep]

# downloadFiles(syn.query, download.location)
# need to prepare tx2gene file as well...
# txi <- loadCountFiles(syn.query,download.location,tx2gene)
# just load it
load("txi.RData")
rownames(metadata.df) <- metadata.df$specimenID

detach("package:synapser", unload=TRUE)
unloadNamespace("PythonEmbedInR")
dds <- DESeqDataSetFromTximport(
  txi = txi,
  colData = metadata.df,
  design = ~ individualID)

# differential expression analysis
dds.result <- DESeq(dds)
res <- results(dds.result)

