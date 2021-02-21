# Data source: UCI ML Credit card default prediction
# Source url: https://archive.ics.uci.edu/ml/datasets/Census+Income
# Competition type: binary classification
# target/response variable to predict: Prediction task is to determine whether a person makes over 50K a year.
# evaluation metric: AUROC
# missing values are coded as ?

# clean the worspace
rm(list = ls())
# load required libraries
library(tidyverse)
# read the data
df <- read.csv("data/uciml_adult_data.csv")
sum(is.na(df)) # 4262 missing values
colSums(is.na(df)) # workclass & native country has missing values

# rearrange the cols
df1 <- df %>%
  arrange(as.numeric, as.character)
str(df)
