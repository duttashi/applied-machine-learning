library(tidyverse)
library(magrittr)

# data source
# https://www.kaggle.com/andrewmvd/heart-failure-clinical-data

# Objective
# Predict death by heart failure. 
# The variable is DEATH_EVENT with values 0= no death, 1 = death
# other categorical variables are
# Sex - Gender of patient Male = 1, Female =0
# Age - Age of patient
# Diabetes - 0 = No, 1 = Yes
# Anaemia - 0 = No, 1 = Yes
# High_blood_pressure - 0 = No, 1 = Yes
# Smoking - 0 = No, 1 = Yes
# DEATH_EVENT - 0 = No, 1 = Yes

# clean the workspace
rm(list = ls())

# load required libraries
library(plyr)
library(Boruta)
library(caret)

# read the data
getwd()
df <- read.csv("data/heart_failure_clinical_records_dataset.csv",
               header = TRUE, sep = ",")
# coerce multiple varaibles to categorical
cols_num <- c("anaemia", "sex","diabetes","high_blood_pressure",
              "smoking","DEATH_EVENT")
df[cols_num]<- lapply(df[,cols_num],factor) 
str(df)
# revalue the predictor column. change 0,1 to yes, no
df$DEATH_EVENT<- revalue(df$DEATH_EVENT, c("0"="No","1"="Yes"))

# feature importance
boruta_output <- Boruta(DEATH_EVENT ~ ., data=df, doTrace=0)
# Get significant variables including tentatives
boruta_signif <- getSelectedAttributes(boruta_output, withTentative = TRUE)
print(boruta_signif)
# Variable Importance Scores
imps <- attStats(boruta_output)
imps2 = imps[imps$decision != 'Rejected', c('meanImp', 'decision')]
head(imps2[order(-imps2$meanImp), ])  # descending sort

# Plot variable importance
plot(boruta_output, cex.axis=.7, las=2, xlab="", main="Variable Importance")

# Alternative methods for feature selection: using machine learning models
set.seed(100)
rPartMod <- train(DEATH_EVENT ~ ., data=df, method="rpart")
rpartImp <- varImp(rPartMod)
print(rpartImp)

# Select only the variables with high importance
df1 <- df[,boruta_signif]
df1$DEATH_EVENT<- df$DEATH_EVENT # add the class variable

# Model building on imbalanced dataset
# split the data into train and test
set.seed(2020)
index <- createDataPartition(df1$DEATH_EVENT, p = 0.7, list = FALSE)
train_data <- df1[index, ]
test_data  <- df1[-index, ]
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary
)
# Build models
# CART
set.seed(2020)

fit_cart<-caret::train(DEATH_EVENT ~ .,data = train_data,
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC"
)
# kNN
set.seed(2020)

fit_knn<-caret::train(DEATH_EVENT ~ .,data = train_data,
                      method = "knn",
                      preProcess = c("scale", "center"),
                      trControl = ctrl 
                      , metric= "ROC"
)

# Logistic Regression
set.seed(2020)
fit_glm<-caret::train(DEATH_EVENT ~ .,data = train_data
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC"
)
# summarize accuracy of models
models <- resamples(list(cart=fit_cart, knn=fit_knn, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_glm, test_data)
confusionMatrix(predictions, test_data$DEATH_EVENT) # 85% accuracy with kappa at 0.63


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

fit_under<-caret::train(DEATH_EVENT ~ .,data = train_data,
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

fit_over<-caret::train(DEATH_EVENT ~ .,data = train_data,
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

fit_rose<-caret::train(DEATH_EVENT ~ .,data = train_data
                       , method = "glm",family = "binomial"
                       , preProcess = c("scale", "center")
                       , trControl = ctrl 
                       , metric= "ROC"
)

# summarize accuracy of models
models <- resamples(list(glm_under=fit_under, glm_over=fit_over, glm_rose=fit_rose))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_under, test_data)
# Using under-balancing as a method for balancing the data
confusionMatrix(predictions, test_data$DEATH_EVENT) # 98% accuracy on balanced under sampled logistic regression model
