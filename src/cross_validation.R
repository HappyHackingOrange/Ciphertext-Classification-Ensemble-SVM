
### VERSION LOG ################################################################################

# 5/13/19  1. Initial code (vxs)



### HEADER CODE ################################################################################

# Clean out environment
rm(list=ls())
gc()



### LIBRARIES ##################################################################################

library(data.table)
library(e1071)
library(ggplot2)
library(caret)



### INPUT ######################################################################################

# Set working directory
setwd("G:/My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/features")

# Load simple substitution ciphertext
DT <- fread(
  file = "100.csv"
)



### CROSS-VALIDATION ###########################################################################

# Get indices for 5-fold CV
idx.folds <- createFolds(
  y = DT[,label],
  k = 5
)

# Convert labels from character to factor
{
  DT[,label.simple := factor(label.simple, levels = c("simple substitution","not simple substitution"))]
  DT[,label.vigenere := factor(label.vigenere, levels = c("vigenere","not vigenere"))]
  DT[,label.column := factor(label.column, levels = c("column transposition","not column transposition"))]
  DT[,label.playfair := factor(label.playfair, levels = c("playfair","not playfair"))]
  DT[,label.hill := factor(label.hill, levels = c("hill cipher","not hill cipher"))]
}

# Train data set using SVM
DT.list <- list()
for (fold in 1:5) {
  # fold <- 1
  
  # Get indicies for training and test sets
  idx.train <- sample(unlist(idx.folds[-fold]))
  idx.test <- idx.folds[[fold]]

  model.simple <- svm(
    formula = label.simple ~ .,
    data = DT[idx.train,.(label.simple,DIC,IC)],
    probability = TRUE
  )
  # plot(
  #   model.simple,
  #   data = DT[,.(label.simple,IC,DIC)]
  # )
  pred.simple <- predict(
    object = model.simple,
    newdata = DT[idx.test,.(label.simple,DIC,IC)],
    probability = TRUE
  )
  
  model.vigenere <- svm(
    formula = label.vigenere ~ .,
    data = DT[idx.train,.(label.vigenere,MIC,IC)],
    probability = TRUE
  )
  # plot(
  #   model.vigenere,
  #   data = DT[,.(label.vigenere,MIC,IC)]
  # )
  pred.vigenere <- predict(
    object = model.vigenere,
    newdata = DT[idx.test,.(label.vigenere,MIC,IC)],
    probability = TRUE
  )
  
  model.column <- svm(
    formula = label.column ~ .,
    data = DT[idx.train,.(label.column,LDI,EDI)],
    probability = TRUE
  )
  # plot(
  #   model.column,
  #   data = DT[,.(label.column,LDI,EDI)]
  # )
  pred.column <- predict(
    object = model.column,
    newdata = DT[idx.test,.(label.column,LDI,EDI)],
    probability = TRUE
  )
  
  model.playfair <- svm(
    formula = label.playfair ~ .,
    data = DT[idx.train,.(label.playfair,EDI,DIC)],
    probability = TRUE
  )
  # plot(
  #   model.playfair,
  #   data = DT[,.(label.playfair,EDI,DIC)]
  # )
  pred.playfair <- predict(
    object = model.playfair,
    newdata = DT[idx.test,.(label.playfair,EDI,DIC)],
    probability = TRUE
  )
  
  model.hill <- svm(
    formula = label.hill ~ .,
    data = DT[idx.train,.(label.hill,EDI,MIC)],
    probability = TRUE
  )
  # plot(
  #   model.hill,
  #   data = DT[idx.train,.(label.hill,EDI,MIC)]
  # )
  pred.hill <- predict(
    object = model.hill,
    newdata = DT[idx.test,.(label.hill,EDI,MIC)],
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
  
  DT.list[[fold]] <- DT.prob[,.(fold = fold,label.actual = DT[idx.test,label],label.predicted = colnames(.SD)[max.col(.SD,ties.method="first")])]

}

DT.prob[,Actual := DT[idx.test,label]]

{
  DT.results <- rbindlist(DT.list)
  DT.results[,Actual := factor(label.actual, levels = c("simple substitution","vigenere","column transposition","playfair","hill cipher"),labels = c("Simple","Vigenere","Column","Playfair","Hill"))]
  DT.results[,Predicted := factor(label.predicted, levels = c("simple substitution","vigenere","column transposition","playfair","hill cipher"),labels = c("Simple","Vigenere","Column","Playfair","Hill"))]
  DT.results[,table(Actual,Predicted)]
  DT.results[,.(Accuracy = sum(diag(table(label.actual,label.predicted)))/length(idx.test)),by=.(fold)][,mean(Accuracy)]
}

DT.acc <- data.table(
  `Ciphertext length` = c(seq.int(30,90,10),seq.int(100,1000,100)),
  Accuracy1 = c(
    0.4396, 0.5080, 0.5842, 0.6634, 0.7236, 0.7684, 0.8004,
    0.8436, 0.9838, 0.9966, 0.9992, 0.9994, 0.9996, 0.9996, 0.9998, 0.9998, 1.0000
  ),
  Accuracy2 = c(
    0.4526, 0.5132, 0.5830, 0.6656, 0.7206, 0.7676, 0.7998,
    0.8440, 0.9832, 0.9968, 0.9992, 0.9994, 0.9996, 0.9996, 0.9998, 0.9998, 1.0000
  )
)

{
  g <- ggplot(
    data = DT.acc,
    mapping = aes(
      x = `Ciphertext length`
    )
  )
  g <- g + geom_line(aes(y=Accuracy1),color="blue",size=2)
  g <- g + geom_line(aes(y=Accuracy2),color="red",size=2)
  g <- g + xlab("Ciphertext length")
  g <- g + coord_cartesian(ylim = c(0,1))
  print(g)
}




