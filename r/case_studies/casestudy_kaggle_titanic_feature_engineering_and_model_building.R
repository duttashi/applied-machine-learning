# Feature Engineering and Classification Model Building
# dataset sourced from: Kaggle
# dataset name: Titanic
# Problem objective: To predict who survived the disaster and who did not
# Evaluation metric: Accuracy

# clean the workspace
rm(list = ls())

# required libraries
library(caret)
library(tidyverse)
# read data in memory
# read the test dataset into a validation_data variable.
# Note: whe you are provided with a dataset that is already split into train and test sets, then what this means is the given test should be used for model validation. And as such, you must split the train dataset into train and test. Build your models on the train set. Check their performance on the test set. And then further fine tune the model and check its performance on the validation (or the original test set.)

df_train <- read.csv("data/kaggle_titanic_train.csv", stringsAsFactors = TRUE, sep = ",")
df_validation<- read.csv("data/kaggle_titanic_test.csv", stringsAsFactors = TRUE, sep = ",")
# recode the response variable values
df_train$Survived <- factor(recode(df_train$Survived,"0"="dead","1"="alive"))

# check data structure and response variable distribution
str(df_train)
str(df_validation) # Note: the validation set does not contain the response variable. This is what we have to predict for each of its row or passenger record.
table(df_train$Survived) # imbalanced response variable

sum(is.na(df_train))
colSums(is.na(df_train)) # age has 177 missing values
# impute the continuous missig values with median

# create a function to impute misisng continuous values with median
impute_median<- function(data = data){
  for(i in 1:ncol(data)){
    if(class(data[,i]) %in% c("numeric","integer")){
      if(sum(is.na(data[,i]))){
        data[is.na(data[,i]), i] <- median(data[,i], na.rm = TRUE)
      } # end innermost if
      } # end if
  } # end for
  return(data)
} # end function

df_train_imputd <- impute_median(df_train)
sum(is.na(df_train_imputd))

# Survived is the response variable. 
# Its a binary variable, where 0 = dead, 1 = survived

# split the train dataset into train and test set
set.seed(2020)
index <- createDataPartition(df_train_imputd$Survived, p = 0.7, list = FALSE)
data_train <- df_train_imputd[index, ]
data_test  <- df_train_imputd[-index, ]
sum(is.na(data_train))
str(data_train)
str(data_test)

# On the basis of response/target/dependent variable choose an initial classifier.
# Now, build an initial baseline model basis of the classifer.
# Check the model performance on the test set.
# Record the accuracy value.
# Next, perform feature engineering, i.e., derive variables from the existing data such that they are not highly collinear to the response variable.
# Build the model again using these new features and test their accuracy.
# Determine, if the accuracy increases or it drops.

# Data resampling:  10-fold cross validation
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary
                     )

# Build Initial models
# recursive Partitioning/Decision Trees 
set.seed(2020)
# drop factor variables with more than 10 levels for now
fit_rpart<-caret::train(Survived ~ .,data = data_train[,-c(4,9,11)],
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC"
                       )

# Generalised Linear Modellig
set.seed(2020)
fit_glm<-caret::train(Survived ~ .,data = data_train[,-c(4,9,11)]
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC")

# summarize accuracy of models
models <- resamples(list(rpart=fit_rpart, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_rpart, data_test)
confusionMatrix(predictions, data_test$Survived) 
# So the baseline accuracy using rpart algorithm is 79%


