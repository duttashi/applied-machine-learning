# Data source: Kaggle Home Loan Default prediction
# Source url: https://www.kaggle.com/c/home-credit-default-risk/overview/description
# Competition type: binary classification
# target/response variable to predict: sig_id
# evaluation metric: AUROC
# challenge aim: 

# load required libraries
library(tidyverse)
library(caret)
# load data
train <- read_csv('data/kag_hln_application_train.csv')
test<- read_csv('data/kag_hln_application_test.csv')

# overview of the data
head(train)
head(test)
# missing values
sum(is.na(train))
sum(is.na(test))
colnames(train)

# coerce target to factor
train$TARGET<- factor(train$TARGET)

ggplot(data = train, aes(x=TARGET))+
  geom_bar()

# FEATURE SELECTION

# 1. Find columns with a missing fraction greater than a specified threshold
# Deleting columns from a data.frame where NA is more than 15% of the column length
# reference: https://stackoverflow.com/questions/11821303/deleting-columns-from-a-data-frame-where-na-is-more-than-15-of-the-column-lengt
train <- train[, colMeans(is.na(train)) <=.15]

# 2. Remove features with zero variance
badCols<- nearZeroVar(train)
train<- train[,-badCols]

# 3. Find collinear features as identified by a correlation coefficient greater than a specified value

