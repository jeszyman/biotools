# load setup from basecamp submodule: 
setwd("~/repos/biotools")
source("./basecamp/src/setup.R")
#
# Check Packages
##
## Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
##
packages = c(
    "ComplexHeatmap",
    "fgsea"
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



