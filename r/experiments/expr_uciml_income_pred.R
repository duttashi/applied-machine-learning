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

# subset all character cols
char_col <- df[, sapply(df, class) == 'character']
str(char_cols)
# convert all character cols to numeric format
df[char_col] <- sapply(df[,colnames(char_col)],as.numeric)
# df<- df %>%
#   mutate_if(is.character, as.numeric)
df[,c(2,4,6:10,14:15)]<- sapply(df[,c(2,4,6:10,14:15)],as.numeric)
str(df)
table(df$workclass)
