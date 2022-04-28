
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
# library(sigFeature)
library(e1071)
library(ggplot2)
library(GGally)
library(caret)



### INPUT ######################################################################################

# Set working directory
setwd("G:/My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/features")

# Load simple substitution ciphertext
DT <- fread(
  file = "100.csv"
)



### FEATURE ELIMATION ##########################################################################

# Generalized pairs plot
columns <- which(!names(DT) %in% c(
  "ciphertext","label","ciphertext0","label.simple","label.vigenere",
  "label.column","label.playfair","label.hill"
))
ggpairs(
  data = DT,
  columns = columns,
  mapping = aes(
    color = label
  )
)

ggpairs(
  data = DT[label %in% c("vigenere","hill cipher")],
  columns = columns,
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

# Simple substitution - IC vs DIC
{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = IC,
      y = DIC,
      color = label
    )
  )
  g <- g + geom_point()
  g <- g + ggtitle("Separating simple substitution from others")
  print(g)
}

# Vigenere - IC vs MIC
{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = IC,
      y = MIC,
      color = label
    )
  )
  g <- g + geom_point()
  g <- g + ggtitle("Separating Vigenere from others")
  print(g)
}

# Columnar transposition - EIC vs LDI
{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = EIC,
      y = LDI,
      color = label
    )
  )
  g <- g + geom_point()
  g <- g + ggtitle("Separating column transposition from others")
  print(g)
}

# Playfair - DIC vs EIC
{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = DIC,
      y = EIC,
      color = label
    )
  )
  g <- g + geom_point()
  g <- g + ggtitle("Separating Playfair from others")
  print(g)
}

# Hill cipher - MIC vs EIC
{
  g <- ggplot(
    data = DT,
    mapping = aes(
      x = MIC,
      y = EIC,
      color = label
    )
  )
  g <- g + geom_point()
  g <- g + ggtitle("Separating Hill cipher from others")
  print(g)
}


