
### VERSION LOG ################################################################################

# 5/13/19  1. Initial code (vxs)



### HEADER CODE ################################################################################

# Clean out environment
rm(list=ls())
gc()



### LIBRARIES ##################################################################################

library(data.table)
library(inline)
# if (!requireNamespace("BiocManager",quietly = TRUE)) install.packages("BiocManager")
# BiocManager::install("sigFeature")
library(sigFeature)


### DEFINITIONS ################################################################################

# Vector of frequency of letters in English language
# Values taken from Pavel Micka's website
rel.freq <- c(
  A = 0.08167, B = 0.01492, C = 0.02782, D = 0.04253, E = 0.12702, F = 0.02228,
  G = 0.02015, H = 0.06094, I = 0.06966, J = 0.00153, K = 0.00772, L = 0.04025,
  M = 0.02406, N = 0.06749, O = 0.07507, P = 0.01929, Q = 0.00095, R = 0.05987,
  S = 0.06327, T = 0.09056, U = 0.07258, V = 0.00978, W = 0.02360, X = 0.00150,
  Y = 0.01974, Z = 0.00074
)

# Table of log digraph frequency scores
logdi <- matrix(
  data = c(
    4,7,8,7,4,6,7,5,7,3,6,8,7,9,3,7,3,9,8,9,6,7,6,5,7,4,
    7,4,2,0,8,1,1,1,6,3,0,7,2,1,7,1,0,6,5,3,7,1,2,0,6,0,
    8,2,5,2,7,3,2,8,7,2,7,6,2,1,8,2,2,6,4,7,6,1,3,0,4,0,
    7,6,5,6,8,6,5,5,8,4,3,6,6,5,7,5,3,6,7,7,6,5,6,0,6,2,
    9,7,8,8,8,7,6,6,7,4,5,8,7,9,7,7,5,9,9,8,5,7,7,6,7,3,
    7,4,5,3,7,6,4,4,7,2,2,6,5,3,8,4,0,7,5,7,6,2,4,0,5,0,
    7,5,5,4,7,5,5,7,7,3,2,6,5,5,7,5,2,7,6,6,6,3,5,0,5,1,
    8,5,4,4,9,4,3,4,8,3,1,5,5,4,8,4,2,6,5,7,6,2,5,0,5,0,
    7,5,8,7,7,7,7,4,4,2,5,8,7,9,7,6,4,7,8,8,4,7,3,5,0,5,
    5,0,0,0,4,0,0,0,3,0,0,0,0,0,5,0,0,0,0,0,6,0,0,0,0,0,
    5,4,3,2,7,4,2,4,6,2,2,4,3,6,5,3,1,3,6,5,3,0,4,0,5,0,
    8,5,5,7,8,5,4,4,8,2,5,8,5,4,8,5,2,4,6,6,6,5,5,0,7,1,
    8,6,4,3,8,4,2,4,7,1,0,4,6,4,7,6,1,3,6,5,6,1,4,0,6,0,
    8,6,7,8,8,6,9,6,8,4,6,6,5,6,8,5,3,5,8,9,6,5,6,3,6,2,
    6,6,7,7,6,8,6,6,6,3,6,7,8,9,7,7,3,9,7,8,9,6,8,4,5,3,
    7,3,3,3,7,3,2,6,7,2,1,7,3,2,7,6,0,7,6,6,6,0,3,0,4,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,
    8,6,6,7,9,6,6,5,8,3,6,6,6,6,8,6,3,6,8,8,6,5,6,0,7,1,
    8,6,7,6,8,6,5,7,8,4,6,6,6,6,8,7,4,5,8,9,7,4,7,0,6,2,
    8,6,6,5,8,6,5,9,8,3,3,6,6,5,9,6,2,7,8,8,7,4,7,0,7,2,
    6,6,7,6,6,4,6,4,6,2,3,7,7,8,5,6,0,8,8,8,3,3,4,3,4,3,
    6,1,0,0,8,0,0,0,7,0,0,0,0,0,5,0,0,0,1,0,2,1,0,0,3,0,
    7,3,3,4,7,3,2,8,7,2,2,4,4,6,7,3,0,5,5,5,2,1,4,0,3,1,
    4,1,4,2,4,2,0,3,5,1,0,1,1,0,3,5,0,1,2,5,2,0,2,2,3,0,
    6,6,6,6,6,6,5,5,6,3,3,5,6,5,8,6,3,5,7,6,4,3,6,2,4,2,
    4,0,0,0,5,0,0,0,3,0,0,2,0,0,3,0,0,0,1,0,2,0,0,0,4,4
  ),
  nrow = 26, byrow = TRUE,
  dimnames = list(LETTERS,LETTERS)
)

# English single letter-digraph discrepancy score table
sdd <- matrix(
  data = c(
    0,3,4,2,0,0,1,0,0,0,4,5,2,6,0,2,0,4,4,3,0,6,0,0,3,5,
    0,0,0,0,6,0,0,0,0,9,0,7,0,0,0,0,0,0,0,0,7,0,0,0,7,0,
    3,0,0,0,2,0,0,6,0,0,8,0,0,0,6,0,5,0,0,0,3,0,0,0,0,0,
    1,6,0,0,1,0,0,0,4,4,0,0,0,0,0,0,0,0,0,1,0,0,4,0,1,0,
    0,0,4,5,0,0,0,0,0,3,0,0,3,2,0,3,6,5,4,0,0,4,3,8,0,0,
    3,0,0,0,0,5,0,0,2,1,0,0,0,0,5,0,0,2,0,4,1,0,0,0,0,0,
    2,0,0,0,1,0,0,6,1,0,0,0,0,0,2,0,0,1,0,0,2,0,0,0,0,0,
    5,0,0,0,7,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,5,0,0,0,4,0,0,0,1,1,3,7,0,0,0,0,5,3,0,5,0,0,0,8,
    0,0,0,0,6,0,0,0,0,0,0,0,0,0,5,0,0,0,0,0,9,0,0,0,0,0,
    0,0,0,0,6,0,0,0,5,0,0,0,0,4,0,0,0,0,0,0,0,0,1,0,0,0,
    2,0,0,4,2,0,0,0,3,0,0,7,0,0,0,0,0,0,0,0,0,0,0,0,7,0,
    5,5,0,0,5,0,0,0,2,0,0,0,0,0,2,6,0,0,0,0,2,0,0,0,6,0,
    0,0,4,7,0,0,8,0,0,2,2,0,0,0,0,0,3,0,0,4,0,0,0,0,0,0,
    0,2,0,0,0,8,0,0,0,0,4,0,5,5,0,2,0,4,0,0,7,4,5,0,0,0,
    3,0,0,0,3,0,0,0,0,0,0,5,0,0,5,7,0,6,0,0,3,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,0,0,0,0,0,
    1,0,0,0,4,0,0,0,2,0,4,0,0,0,2,0,0,0,0,0,0,0,0,0,5,0,
    1,1,0,0,0,0,0,1,2,0,0,0,0,0,1,4,4,0,1,4,2,0,4,0,0,0,
    0,0,0,0,0,0,0,8,3,0,0,0,0,0,3,0,0,0,0,0,0,0,2,0,0,0,
    0,4,3,0,0,0,5,0,0,0,0,6,2,3,0,6,0,6,5,3,0,0,0,0,0,6,
    0,0,0,0,8,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    6,0,0,0,2,0,0,6,6,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,
    3,0,7,0,1,0,0,0,2,0,0,0,0,0,0,9,0,0,0,5,0,0,0,6,0,0,
    1,6,2,0,0,2,0,0,0,6,0,0,2,0,6,2,1,0,2,1,0,0,6,0,0,0,
    2,0,0,0,8,0,0,0,0,6,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,9
  ),
  nrow = 26, byrow = TRUE,
  dimnames = list(LETTERS,LETTERS)
)



### FUNCTIONS ##################################################################################

# Find number of unique characters
# Efficive algorithm taken from 
# https://stackoverflow.com/questions/34872838/r-count-the-number-of-unique-characters-in-that-string
.char_unique_code <- "
std::vector < std::string > s = as< std::vector < std::string > >(x);
unsigned int input_size = s.size();

std::vector < std::string > chrs(input_size);

for (unsigned int i=0; i<input_size; i++) {

std::string t = s[i];

for (std::string::iterator chr=t.begin();
chr != t.end(); ++chr) {

if (chrs[i].find(*chr) == std::string::npos) {
chrs[i] += *chr;
}

}

}
return(wrap(chrs));
"
char_unique <- 
  rcpp(sig=signature(x="std::vector < std::string >"),
       body=.char_unique_code,
       includes=c("#include <string>",
                  "#include <iostream>"))
char_ct_unique <- function(x) nchar(char_unique(x))

# Measure of how similar a frequency distribution is to uniform distribution
getIC <- function (ciphertext) {
  f <- table(strsplit(ciphertext,""))
  L <- nchar(ciphertext)
  sum(f*(f-1))/(L*(L-1))
}

# Create a sequence of letter which is every ith (period) letter of the ciphertext
gatherLetters <- function (x, start, period) {
  paste(strsplit(x,"")[[1]][seq.int(start,nchar(x),period)],collapse = "")
}

# Shift cipherletter to the right by specified amount
shiftLetters <- function (x, shift) {
  if (shift == 0) return(x)
  vec <- strsplit(x,"")[[1]]
  paste(vec[c((shift+1):length(vec),1:shift)],collapse = "")
}

# Find number of characters for which strings starting at c and d are identical
findN <- function (ciphertext,apart) {
  L <- nchar(ciphertext)
  pos <- which(strsplit(substr(ciphertext,1,L-(apart+1)),"")[[1]] != strsplit(substr(ciphertext,(apart+2),L),"")[[1]])
  if (length(pos) == 0) return(0)
  min(pos)-1
}

# Calculate proportion of odd-spaced repeats to all repeats
findROD <- function (ciphertext) {
  L <- nchar(ciphertext)
  Ns <- sapply(0:(L-3), function(apart) findN(ciphertext,apart))
  if (sum(Ns>1)==0) return(0)
  sum(Ns[seq.int(1,(L-3),2)]>1)/sum(Ns>1)
}

# Calculate log digraph frequency score at position of ciphertext
get_LDI_Score <- function (ciphertext,pos) {
  str <- strsplit(ciphertext,"")[[1]]
  logdi[str[pos],str[pos+1]]
}

# Get English single letter-digraph discrepancy score table at position of ciphertext
get_SDD_Score <- function (ciphertext,pos) {
  str <- strsplit(ciphertext,"")[[1]]
  sdd[str[pos],str[pos+1]]
}



### INPUT ######################################################################################

# Set working directory
setwd("G:My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/data")

# Load simple substitution ciphertext
DT <- fread(
  text = "ciphertext_simple.txt",
  header = FALSE,
  col.names = "ciphertext"
)

# Ensure that there are 1000 ciphertexts with 1000 character each
DT[,table(sapply(ciphertext,nchar))]

# Add column to tell us this is Simple Subtitution ciphertext
DT[,label := "simple subtitution"]


# Load Vigenere ciphertext
DT.tmp <- fread(
  text = "ciphertext_vigenere.txt",
  header = FALSE,
  col.names = "ciphertext"
)

# Ensure that there are 1000 ciphertexts with 1000 character each
DT.tmp[,table(sapply(ciphertext,nchar))]

# Add column to tell us this is Vigenere ciphertext
DT.tmp[,label := "vigenere"]

# Bind Vigenere ciphertexts to main data table
DT <- rbindlist(list(DT,DT.tmp))


# Load Column Transposition ciphertext
DT.tmp <- fread(
  text = "ciphertext_column.txt",
  header = FALSE,
  col.names = "ciphertext"
)

# Ensure that there are 1000 ciphertexts with 1000 character each
DT.tmp[,table(sapply(ciphertext,nchar))]

# Add column to tell us this is column transposition ciphertext
DT.tmp[,label := "column transposition"]

# Bind column transposition ciphertexts to main data table
DT <- rbindlist(list(DT,DT.tmp))


# Load Playfair ciphertext
DT.tmp <- fread(
  file = "Playfair.csv",
  col.names = c(NA,NA,"ciphertext",NA)
)

# Ensure that there are 1000 ciphertexts with 1000 character each
DT.tmp[,table(sapply(ciphertext,nchar))]

# Playfair ciphertexts are not in lengths of 1000. Trim them all.
DT.tmp[,ciphertext:= strtrim(ciphertext,1000)]

# Add column to tell us this is Playfair ciphertext
DT.tmp[,label := "playfair"]

# Bind column transposition ciphertexts to main data table
DT <- rbindlist(list(DT,DT.tmp[,.(ciphertext,label)]))


# Load Hill ciphertext
DT.tmp <- fread(
  text = "ciphertext_hill.txt",
  header = FALSE,
  col.names = "ciphertext"
)

# Ensure that there are 1000 ciphertexts with 1000 character each
DT.tmp[,table(sapply(ciphertext,nchar))]

# Add column to tell us this is hill ciphertext
DT.tmp[,label := "hill cipher"]

# Bind column transposition ciphertexts to main data table
DT <- rbindlist(list(DT,DT.tmp))

# Remove temp data.table
rm(DT.tmp)

# Uppercase all letters
DT[,ciphertext := toupper(ciphertext)]

# Keep original ciphertext
DT[,ciphertext0 := ciphertext]



### FEATURE GENERATION #########################################################################

# Vary ciphertext lengths
for (len in 997:3) {
cat("\nCiphertext length:",len,"\n")
  
# Trim
DT[,ciphertext := strtrim(ciphertext0,len)]

# Number of unique characters (NUC) 
{
  time.start <- Sys.time()
  DT[,NUC := char_ct_unique(ciphertext)]
  time.end <- Sys.time()
  cat("NUC:",time.end-time.start,"secs\n")
}

# Chi-squared statistic of English distribution (CSS)
{
  time.start <- Sys.time()
  DT[,CSS := sapply(ciphertext, function (x) sum((table(strsplit(x,""))-rel.freq[names(table(strsplit(x,"")))]*nchar(x))^2/(rel.freq[names(table(strsplit(x,"")))]*nchar(x))))]
  time.end <- Sys.time()
  cat("CSS:",time.end-time.start,"secs\n")
}

# Index of coincidence (IC)
{
  time.start <- Sys.time()
  DT[,IC := 1000*sapply(ciphertext, getIC)]
  time.end <- Sys.time()
  cat("IC:",time.end-time.start,"secs\n")
}

# Max IC for periods 1-15 (MIC)
{
  time.start <- Sys.time()
  DT[,MIC := 1000*sapply(ciphertext,function (ct) max(sapply(1:15,function (period) mean(sapply(1:period,function (start) getIC(gatherLetters(ct,start,period)))))))]
  time.end <- Sys.time()
  cat("MIC:",time.end-time.start,"secs\n")
}

# Max kappa for periods 1-15 (MKA)
{
  time.start <- Sys.time()
  DT[,MKA := 1000*sapply(ciphertext,function(ct) max(sapply(1:15,function(x) sum(strsplit(ct,"")[[1]]==strsplit(shiftLetters(ct,x),"")[[1]])/nchar(ct))))]
  time.end <- Sys.time()
  cat("MKA:",time.end-time.start,"secs\n")
}

# Diagraphic index of coincidence (DIC)
{
  time.start <- Sys.time()
  DT[,DIC := 10000*sapply(ciphertext,function(ct) {
    L <- nchar(ct)
    f <- table(sapply(1:(L-1),function(x) substr(ct,x,x+1)))
    sum(f*(f-1))/((L-1)*(L-2))
  })]
  time.end <- Sys.time()
  cat("DIC:",time.end-time.start,"secs\n")
}

# DIC for even number of pairs (EDI)
{
  time.start <- Sys.time()
  DT[,EIC := 10000*sapply(ciphertext,function(ct) {
    L <- nchar(ct)
    f <- table(sapply(seq(1,(L-1),2),function(x) substr(ct,x,x+1)))
    2*sum(f*(f-1))/(L*(L-2))
  })]
  time.end <- Sys.time()
  cat("EIC:",time.end-time.start,"secs\n")
}

# Long repeats (percentage of 3 character repeats)
{
  time.start <- Sys.time()
  DT[,LR := 1000*sqrt(sapply(ciphertext,function(ct) {
    L <- nchar(ct)
    f <- table(sapply(1:(L-2),function(x) substr(ct,x,x+2)))
    sum(f-1)/L
  }))]
  time.end <- Sys.time()
  cat("LR:",time.end-time.start,"secs\n")
}

# Percentage of odd-spaced repeats to all repeats (ROD)
{
  time.start <- Sys.time()
  DT[,ROD := 100*sapply(ciphertext,findROD)]
  time.end <- Sys.time()
  cat("ROD:",time.end-time.start,"secs\n")
}

# Average English log diagraph score (LDI)
{
  time.start <- Sys.time()
  DT[,LDI := sapply(ciphertext, function (ct) mean(sapply(1:(nchar(ct)-1),function (x) get_LDI_Score(ct,x))))]
  time.end <- Sys.time()
  cat("LDI:",time.end-time.start,"secs\n")
}

# Average English single letter digraph discrepancy score (SDD)
{
  time.start <- Sys.time()
  DT[,SDD := sapply(ciphertext, function (ct) mean(sapply(1:(nchar(ct)-1),function (x) get_SDD_Score(ct,x))))]
  time.end <- Sys.time()
  cat("SDD:",time.end-time.start,"secs\n")
}

# Get statistical info on cryptanalysis measures
# DT[,.(
#   NUC.mean=mean(NUC),NUC.sd=sd(NUC),
#   CSS.mean=mean(CSS),CSS.sd=sd(CSS),
#   IC.mean=mean(IC),IC.sd=sd(IC),
#   MIC.mean=mean(MIC),MIC.sd=sd(MIC),
#   MKA.mean=mean(MKA),MKA.sd=sd(MKA),
#   DIC.mean=mean(DIC),DIC.sd=sd(DIC),
#   EIC.mean=mean(EIC),EIC.sd=sd(EIC),
#   LR.mean=mean(LR),LR.sd=sd(LR),
#   ROD.mean=mean(ROD),ROD.sd=sd(ROD),
#   LDI.mean=mean(LDI),LDI.sd=sd(LDI),
#   SDD.mean=mean(SDD),SDD.sd=sd(SDD)
# ) ,by=.(label)]

# Save the results
fwrite(DT,paste0("G:/My Drive/University/SJSU/2019Spring/CS271 Machine Learning/Finals/features/",DT[1,nchar(ciphertext)],".csv"))

}



                                                          
