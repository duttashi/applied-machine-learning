# Data source: Flu Shot Learning: Predict H1N1 and Seasonal Flu Vaccines
# Source url: https://www.drivendata.org/competitions/66/flu-shot-learning/page/211/#features_list
# Competition type: binary classification
# target/response variable to predict: h1n1_vaccine & seasonal_vaccine
# evaluation metric: ROC AUC for each of the two target variables. The mean of these two scores will be the overall score. A higher value indicates stronger performance.
# challenge aim: 

# clean the worspace
rm(list = ls())

# load required libraries
library(readr) # for read_csv()
library(plyr) # for revalue()
library(caret) # for nearZeroVar()
library(mice)
# load data
train <- read_csv('data/drivendata_h1n1flu_train_data.csv',
                  na = c("","NA"))
test<- read_csv('data/drivendata_h1n1flu_test_data.csv',
                na = c("","NA"))
# missing values
sum(is.na(train))
sum(is.na(test))
colnames(train)

# 1. Find columns with a missing fraction greater than a specified threshold
# Deleting columns from a data.frame where NA is more than 15% of the column length
train <- train[, colMeans(is.na(train)) <= .15]
test <- test[, colMeans(is.na(test)) <= .15]

# 2. Remove features with zero variance
badCols<- nearZeroVar(train)
train<- train[,-badCols]
badCols<- nearZeroVar(test)
test<- test[,-badCols]

# 3. Rearrange character and numeric vars
# separate character and numeric cols apart
charcols <- colnames(train[,sapply(train, is.character)])
numcols <- colnames(train[, sapply(train, is.numeric)])
# rearrange cols such that numeric cols are first followed by character cols
train<- train[,c(numcols,charcols)] 
str(train)
colnames(train) # character cols begins from index 23

# Impute missing values for numeric variables
# train<-data.frame(lapply(train,function(x) {
#   if(is.numeric(x)) ifelse(is.na(x),median(x,na.rm=T),x) else x}))
# colSums(is.na(train))
