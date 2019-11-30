
### VERSION LOG ################################################################################

# 5/13/19  1. Initial code (vxs)



### HEADER CODE ################################################################################

# Clean out environment
rm(list=ls())
gc()



### LIBRARIES ##################################################################################

# if (!requireNamespace("BiocManager",quietly = TRUE)) install.packages("BiocManager")
# BiocManager::install("sigFeature")
# install.packages("pillar")
library(data.table)
library(sigFeature)
library(e1071)
library(ggplot2)
library(GGally)



### DEFINITIONS ################################################################################



### FUNCTIONS ##################################################################################



### INPUT ######################################################################################

# Set working directory
setwd("G:/My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/features")

# Load simple substitution ciphertext
DT <- fread(
  file = "1000.csv"
)



### FEATURE ELIMATION ##########################################################################

# Calculate unadjusted p-value for each features using t-statistic
pvals <- sigFeaturePvalue(
  x = as.matrix(DT[,.(NUC,CSS,IC,MIC,MKA,DIC,EIC,LR,ROD,LDI,SDD)]),
  y = DT[,label]
)

# Significiantly select features using SVM-RFE and t-statistic
system.time(sigfeatureRankedList <- sigFeature(
  X = as.matrix(DT[,.(NUC,CSS,IC,MIC,MKA,DIC,EIC,LR,ROD,LDI,SDD)]),
  Y = DT[,label]
))
print(sigfeatureRankedList)

ggpairs(
  data = DT,
  columns = 3:13,
  mapping = aes(
    color = label
  )
)

{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = SDD,
      y = LDI,
      color = label
    )
  )
  g <- g + geom_point()
  print(g)
}

{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = SDD,
      y = LR,
      color = label
    )
  )
  g <- g + geom_point()
  print(g)
}

{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = MIC,
      y = DIC,
      color = label
    )
  )
  g <- g + geom_point()
  print(g)
}

# Train data set using 


