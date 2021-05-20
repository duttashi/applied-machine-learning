# Data Source: https://www.kaggle.com/paresh2047/uci-semcom
# Data source original: https://archive.ics.uci.edu/ml/datasets/SECOM

# Objective
# Using feature selection techniques it is desired to rank features according to their impact on the overall yield for the product, causal relationships may also be considered with a view to identifying the key features.

# Output
# Results may be submitted in terms of feature relevance for predictability using error rates as our evaluation metrics. It is suggested that cross validation be applied to generate these results. Some baseline results are shown below for basic feature selection techniques using a simple kernel ridge classifier and 10 fold cross validation.

# Type of task: feature selection for dimensionality reduction followed by classification
# required libraries
library(tidyverse)

# Exploratory Data Analysis
df<- read_csv("data/kaggle_uci-secom.csv", na = c("", NA))
dim(df) # 1567 rows 592 cols
sum(is.na(df)) # 41951 missing values
colSums(is.na(df))
str(df$Time) # all variables are quantitative in nature
# show colnames with missing data
which(is.na(df))

# split Time into date, time cols
df1 <- df %>%
  mutate(DATE = as.character(Time)) %>%
  separate(DATE, into = c("DATE", "Time"), sep = " ") %>%
  mutate(DATE = as.Date(DATE))

# 1. Dimensionality reduction 
# A. Remove variables with 70% missing data

## base R solution
# df_mis<- df[which(rowMeans(!is.na(df)) >0.8),]

# Tidyverse solution
df1<-df1 %>%
  purrr::discard(~sum(is.na(.x))/length(.x)* 100 >=70) # 7 vars removed

# B. Remove variables having high correlation with target variable

# C. Remove vars with standard deviation of zero
df1<- df1[apply(df1, 2, sd, na.rm=TRUE)!=0]
colnames(df1)
