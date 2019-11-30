
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



### DEFINITIONS ################################################################################



### FUNCTIONS ##################################################################################



### INPUT ######################################################################################

# Set working directory
setwd("G:/My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/features")

# Load simple substitution ciphertext
DT <- fread(
  file = "100.csv"
)

DT.test <- fread(
  file = "100_test.csv"
)



### FEATURE ELIMATION ##########################################################################

# # Calculate unadjusted p-value for each features using t-statistic
# pvals <- sigFeaturePvalue(
#   x = as.matrix(DT[,.(NUC,CSS,IC,MIC,MKA,DIC,EIC,LR,ROD,LDI,SDD)]),
#   y = DT[,label]
# )
# 
# # Significiantly select features using SVM-RFE and t-statistic
# system.time(sigfeatureRankedList <- sigFeature(
#   X = as.matrix(DT[,.(NUC,CSS,IC,MIC,MKA,DIC,EIC,LR,ROD,LDI,SDD)]),
#   Y = DT[,label]
# ))
# print(sigfeatureRankedList)

# Generalized pairs plot
# ggpairs(
#   data = DT,
#   columns = 3:13,
#   mapping = aes(
#     color = label
#   )
# )

# {
#   g <- ggplot(
#     data = DT,
#     mapping = aes(
#       x = SDD,
#       y = LDI,
#       color = label
#     )
#   )
#   g <- g + geom_point()
#   print(g)
# }

# Simple substitution - IC vs DIC
# {
#   g <- ggplot(
#     data = DT,
#     mapping = aes(
#       x = IC,
#       y = DIC,
#       color = label
#     )
#   )
#   g <- g + geom_point()
#   g <- g + ggtitle("Separating simple substitution from others")
#   print(g)
# }

# Vigenere - IC vs MIC
# {
#   g <- ggplot(
#     data = DT,
#     mapping = aes(
#       x = IC,
#       y = MIC,
#       color = label
#     )
#   )
#   g <- g + geom_point()
#   g <- g + ggtitle("Separating Vigenere from others")
#   print(g)
# }

# Columnar transposition - EIC vs LDI
# {
#   g <- ggplot(
#     data = DT,
#     mapping = aes(
#       x = EIC,
#       y = LDI,
#       color = label
#     )
#   )
#   g <- g + geom_point()
#   g <- g + ggtitle("Separating column transposition from others")
#   print(g)
# }

# Playfair - DIC vs EIC
# {
#   g <- ggplot(
#     data = DT,
#     mapping = aes(
#       x = DIC,
#       y = EIC,
#       color = label
#     )
#   )
#   g <- g + geom_point()
#   g <- g + ggtitle("Separating Playfair from others")
#   print(g)
# }

# Hill cipher - MIC vs EIC
# {
#   g <- ggplot(
#     data = DT,
#     mapping = aes(
#       x = MIC,
#       y = EIC,
#       color = label
#     )
#   )
#   g <- g + geom_point()
#   g <- g + ggtitle("Separating Hill cipher from others")
#   print(g)
# }

# Get indices for 5-fold CV
# idx.folds <- createFolds(
#   y = DT[,label],
#   k = 5
# )

# Convert labels from character to factor
DT[,label.simple := factor(label.simple, levels = c("simple substitution","not simple substitution"))]
DT[,label.vigenere := factor(label.vigenere, levels = c("vigenere","not vigenere"))]
DT[,label.column := factor(label.column, levels = c("column transposition","not column transposition"))]
DT[,label.playfair := factor(label.playfair, levels = c("playfair","not playfair"))]
DT[,label.hill := factor(label.hill, levels = c("hill cipher","not hill cipher"))]

# Train data set using SVM
DT.list <- list()
# for (fold in 1:5) {
  # fold <- 1
  
  # Get indicies for training and test sets
  # idx.train <- sample(unlist(idx.folds[-fold]))
  # idx.test <- idx.folds[[fold]]

  model.simple <- svm(
    formula = label.simple ~ .,
    # data = DT[idx.train,.(label.simple,DIC,IC)],
    data = DT[,.(label.simple,DIC,IC)],
    probability = TRUE
  )
  # plot(
  #   model.simple,
  #   data = DT[,.(label.simple,IC,DIC)]
  # )
  pred.simple <- predict(
    object = model.simple,
    # newdata = DT[idx.test,.(label.simple,DIC,IC)],
    newdata = DT.test[,.(DIC,IC)],
    probability = TRUE
  )
  
  model.vigenere <- svm(
    formula = label.vigenere ~ .,
    # data = DT[idx.train,.(label.vigenere,MIC,IC)],
    data = DT[,.(label.vigenere,MIC,IC)],
    probability = TRUE
  )
  # plot(
  #   model.vigenere,
  #   data = DT[,.(label.vigenere,MIC,IC)]
  # )
  pred.vigenere <- predict(
    object = model.vigenere,
    # newdata = DT[idx.test,.(label.vigenere,MIC,IC)],
    newdata = DT.test[,.(MIC,IC)],
    probability = TRUE
  )
  
  model.column <- svm(
    formula = label.column ~ .,
    # data = DT[idx.train,.(label.column,LDI,EIC)],
    data = DT[,.(label.column,LDI,EDI)],
    probability = TRUE
  )
  # plot(
  #   model.column,
  #   data = DT[,.(label.column,LDI,EIC)]
  # )
  pred.column <- predict(
    object = model.column,
    newdata = DT.test[,.(LDI,EDI)],
    probability = TRUE
  )
  
  model.playfair <- svm(
    formula = label.playfair ~ .,
    # data = DT[idx.train,.(label.playfair,EIC,DIC)],
    data = DT[,.(label.playfair,EDI,DIC)],
    probability = TRUE
  )
  # plot(
  #   model.playfair,
  #   data = DT[,.(label.playfair,EIC,DIC)]
  # )
  pred.playfair <- predict(
    object = model.playfair,
    # newdata = DT[idx.test,.(label.playfair,EDI,DIC)],
    newdata = DT.test[,.(EDI,DIC)],
    probability = TRUE
  )
  
  model.hill <- svm(
    formula = label.hill ~ .,
    # data = DT[idx.train,.(label.hill,EDI,MIC)],
    data = DT[,.(label.hill,EDI,MIC)],
    probability = TRUE
  )
  # plot(
  #   model.hill,
  #   data = DT[idx.train,.(label.hill,EIC,MIC)]
  # )
  pred.hill <- predict(
    object = model.hill,
    # newdata = DT[idx.test,.(label.hill,EDI,MIC)],
    newdata = DT.test[,.(EDI,MIC)],
    probability = TRUE
  )
  
  # Put all probability values together in one matrix
  DT.prob <- data.table(
    # `simple substitution` = attr(pred.simple,"probabilities")[,"simple substitution"]*attr(pred.vigenere,"probabilities")[,"not vigenere"]*attr(pred.column,"probabilities")[,"not column transposition"]*attr(pred.playfair,"probabilities")[,"not playfair"]*attr(pred.hill,"probabilities")[,"not hill cipher"],
    # `vigenere` = attr(pred.simple,"probabilities")[,"not simple substitution"]*attr(pred.vigenere,"probabilities")[,"vigenere"]*attr(pred.column,"probabilities")[,"not column transposition"]*attr(pred.playfair,"probabilities")[,"not playfair"]*attr(pred.hill,"probabilities")[,"not hill cipher"],
    # `column transposition` = attr(pred.simple,"probabilities")[,"not simple substitution"]*attr(pred.vigenere,"probabilities")[,"not vigenere"]*attr(pred.column,"probabilities")[,"column transposition"]*attr(pred.playfair,"probabilities")[,"not playfair"]*attr(pred.hill,"probabilities")[,"not hill cipher"],
    # `playfair` = attr(pred.simple,"probabilities")[,"not simple substitution"]*attr(pred.vigenere,"probabilities")[,"not vigenere"]*attr(pred.column,"probabilities")[,"not column transposition"]*attr(pred.playfair,"probabilities")[,"playfair"]*attr(pred.hill,"probabilities")[,"not hill cipher"],
    # `hill cipher` = attr(pred.simple,"probabilities")[,"not simple substitution"]*attr(pred.vigenere,"probabilities")[,"not vigenere"]*attr(pred.column,"probabilities")[,"not column transposition"]*attr(pred.playfair,"probabilities")[,"not playfair"]*attr(pred.hill,"probabilities")[,"hill cipher"]
    `simple substitution` = attr(pred.simple,"probabilities")[,"simple substitution"],
    `vigenere` = attr(pred.vigenere,"probabilities")[,"vigenere"],
    `column transposition` = attr(pred.column,"probabilities")[,"column transposition"],
    `playfair` = attr(pred.playfair,"probabilities")[,"playfair"],
    `hill cipher` = attr(pred.hill,"probabilities")[,"hill cipher"]
  )
  
  DT.predicted <- DT.prob[,.(label.predicted = colnames(.SD)[max.col(.SD,ties.method="first")])]
  print(DT.predicted)
  DT.predicted[,table(label.predicted)]

# }
  
DT.predicted[label.predicted == "simple substitution",label.abbr := "S"]
DT.predicted[label.predicted == "column transposition",label.abbr := "C"]
DT.predicted[label.predicted == "vigenere",label.abbr := "V"]
DT.predicted[label.predicted == "playfair",label.abbr := "P"]
DT.predicted[label.predicted == "hill cipher",label.abbr := "H"]
DT.predicted[,table(label.abbr)]

fileConn <- file("G:/My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/results.txt")
DT.predicted[,writeLines(label.abbr,fileConn)]
close(fileConn)

# DT.results <- rbindlist(DT.list)
# DT.results[,label.actual := factor(label.actual, levels = c("simple substitution","vigenere","column transposition","playfair","hill cipher"))]
# DT.results[,label.predicted := factor(label.predicted, levels = c("simple substitution","vigenere","column transposition","playfair","hill cipher"))]
# 
# length(idx.test)
# DT.results[,.(Accuracy = sum(diag(table(label.actual,label.predicted)))/length(idx.test)),by=.(fold)][,mean(Accuracy)]


