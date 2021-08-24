
# data source
# https://www.kaggle.com/sureshmecad/predict-a-doctors-consultation-fee

# required libraries
library(tidyverse)

# Exploratory Data Analysis
df_train<- read_csv("data/kaggle_docfee_train.csv", na = c("", NA))
df_test<- read_csv("data/kaggle_docfee_test.csv", na = c("", NA))
dim(df_train) # 5961 rows 7 cols
sum(is.na(df_train)) # 5947 missing values
colSums(is.na(df_train)) # both train & test have same cols with missing values
colSums(is.na(df_test))
colnames(df_train)
colnames(df_test)

