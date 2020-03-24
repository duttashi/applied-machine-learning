# Script create date: 17/7/2019
# script last modified date: 17/7/2019
# Objective: In this competition you are predicting the probability that an online transaction is fraudulent, as denoted by the binary target isFraud
# Data description: The data is broken into two files identity and transaction, which are joined by TransactionID. Not all transactions have corresponding identity information.
# Reference: https://www.kaggle.com/c/ieee-fraud-detection/

# EDA

# required libraries
library(data.table) # for fread()
library(magrittr) # for the pipe operator
# read the data

getwd()
list.files('/data')
train_identity<- fread("data/kaggle-ieee-fraud-detection/train_identity.csv") %>%
  data.frame()
test_identity <- fread("data/kaggle-ieee-fraud-detection/test_identity.csv") %>%
  data.frame()

