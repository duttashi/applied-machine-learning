
# census income dataset
# source: https://www.kaggle.com/uciml/adult-census-income
# http://archive.ics.uci.edu/ml/datasets/Census+Income
# Target variable: 
# variable types: mixed
# Q to solve: Prediction task is to determine whether a person makes over 50K a year.
# Problem type: Classification
# Evaluation metric: ROC

# load required libraries
library(tidyverse)
library(caret)
# clean the workspace
rm(list = ls())

# get the data
data <- read.csv("data/census-income.csv", sep = ",", 
                 header = TRUE, stringsAsFactors = TRUE)

# data structure
table(data$income) # imbalanced target variable

# tidy data

# 1. recode <=50k as 0 and >50k as 1
data$income <- recode(data$income,">50K"="above_50K","<=50K"="below_equal_50K")
# 2. replace ? with NA
data$workclass<- recode(data$workclass, "?"= "NA")
data$occupation<- recode(data$occupation,"?"="NA")
data$native.country<- recode(data$native.country,"?"="NA")

# modelling without data balancing
# check for near zero variance
badcols<- nearZeroVar(data)
dim(data[,badcols]) # 3 cols with near zero variance property
names(data[,badcols])
data_rev<- data[,-badcols]

# Data splitting
set.seed(2020)
index <- createDataPartition(data_rev$income, p = 0.7, list = FALSE)
train_data <- data_rev[index, ]
test_data  <- data_rev[-index, ]

# Data resampling:  10-fold cross validation
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary
                     )
# Build models

# recursive Partitioning/Decision Trees 
set.seed(2020)
fit_cart<-caret::train(income ~ .,data = train_data,
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC"
                       )

# Generalised Linear Modellig
set.seed(2020)
fit_glm<-caret::train(income ~ .,data = train_data
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC")

# # Logistic Regression
# set.seed(2020)
# fit_logreg<-caret::train(income ~ .,data = train_data
#                       , method = "logreg", family = "binomial"
#                       , preProcess = c("scale", "center")
#                       , trControl = ctrl
#                       , metric= "ROC"
#                       )

# summarize accuracy of models
models <- resamples(list(cart=fit_cart, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_glm, test_data)
confusionMatrix(predictions, test_data$income) # 83% accuracy with kappa at 0.52 o imbalanced data

# PREDICTIVE MODELLING On BALANCED DATA
# Method 1: Under Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "down"
                     )

fit_under<-caret::train(income ~ .,data = train_data,
                        method = "glm",family = "binomial"
                        ,preProcess = c("scale", "center"),
                        trControl = ctrl,metric= "ROC")

# Method 2: Over Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "up"
)

fit_over<-caret::train(income ~ .,data = train_data,
                       method = "glm",family = "binomial"
                       ,preProcess = c("scale", "center"),
                       trControl = ctrl, 
                       metric= "ROC"
)
# Method 3: Hybrid Sampling (ROSE)
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE
                     , summaryFunction=twoClassSummary
                     , sampling = "rose"
)


# summarize accuracy of models
models <- resamples(list(glm_under=fit_under, glm_over=fit_over))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_under, test_data)
# Using under-balancing as a method for balancing the data
confusionMatrix(predictions, test_data$income) # 79% accuracy on balanced under sampled geberalised linear model


