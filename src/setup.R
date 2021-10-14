#
# Check Packages
##
## Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
##
packages = c(
  "AnnotationDbi",
  "biomaRt",
  "circlize",
  "ComplexHeatmap",
  "copynumber",
  "DESeq2",
  "DRIMSeq",
  "edgeR",
  "fgsea",
  "gage",
  "gageData",  
  "GenomicFeatures",
  "gplots",
  "limma",
  "pathview",
  "pheatmap",
  "PoiClaClu",
  "SummarizedExperiment",
  "tximport"
)
##
##NOTE requires libcurl4-openssl-dev https://stackoverflow.com/questions/11471690/curl-h-no-such-file-or-directory/11471743
package.check = lapply(
  packages,
  FUN = function(x) {
    if (!require (x, character.only = T)) {      
      BiocManager::install(x, quietly =T, ask=F)
      library(x, character.only = T)
    }
  }
)
#
