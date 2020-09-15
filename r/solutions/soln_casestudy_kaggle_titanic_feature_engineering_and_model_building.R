# Feature Engineering and Classification Model Building
# dataset sourced from: Kaggle https://www.kaggle.com/c/titanic/data
# dataset name: Titanic
# Problem objective: To predict who survived the disaster and who did not
# Evaluation metric: Accuracy
# Survival	0 = No, 1 = Yes

# clean the workspace
rm(list = ls())

# required libraries
library(caret)
library(tidyverse)
# read data in memory
# read the test dataset into a validation_data variable.
# Note: whe you are provided with a dataset that is already split into train and test sets, then what this means is the given test should be used for model validation. And as such, you must split the train dataset into train and test. Build your models on the train set. Check their performance on the test set. And then further fine tune the model and check its performance on the validation (or the original test set.)

data_train <- read.csv("data/kaggle_titanic_train.csv", stringsAsFactors = TRUE, sep = ",", na.strings = c(""))
data_test<- read.csv("data/kaggle_titanic_test.csv", stringsAsFactors = TRUE, sep = ",", na.strings = c(""))

# bind the two datasets together
# data_train<- bind_rows(data_train, data_test)
# recode the response variable values
data_train$Survived <- factor(recode(data_train$Survived,"0"="dead","1"="alive"))

# check data structure and response variable distribution
str(data_train)
table(data_train$Survived) # imbalanced response variable

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

# create a mode()
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
# create a function to impute misisng categorical values with mode
impute_mode<- function(data = data){
  for(i in 1:ncol(data)){
    if(class(data[,i]) %in% c("factor","character")){
      if(sum(is.na(data[,i]))){
        data[is.na(data[,i]), i] <- Mode(na.omit(data[,i]))
      } # end innermost if
    } # end if
  } # end for
  return(data)
} # end function


data_train <- impute_median(data_train)
data_train <- impute_mode(data_train)
sum(is.na(data_train))
colSums(is.na(data_train))
# Survived is the response variable. 
# Its a binary variable, where 0 = dead, 1 = survived

# split the train dataset into train and test set
set.seed(2020)
index <- createDataPartition(data_train$Survived, p = 0.7, list = FALSE)
df_train <- data_train[index, ]
df_test  <- data_train[-index, ]


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
fit_rpart<-caret::train(Survived ~ .,data = df_train[,-c(4,9,11)],
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC"
                       )

# Generalised Linear Modellig
set.seed(2020)
fit_glm<-caret::train(Survived ~ .,data = df_train[,-c(4,9,11)]
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
predictions <- predict(fit_rpart, df_test)
confusionMatrix(predictions, df_test$Survived) 
# So the baseline accuracy using rpart algorithm is 75%


# Feature Engineering

# look at the name variable
data_train$title<- str_extract(data_train$Name ,
                             pattern = "(Mr|Master|Mrs|Miss|Dr|Major|Countess|Rev)\\.")
# coerce title to factor type. If not changed then glm model throws warning prediction from a rank-deficient fit may be misleading
data_train$title<- factor(data_train$title)

# look at the age variable
# Use the age variable to create a new binned variable age_group
# age group classification based on https://www.statcan.gc.ca/eng/concepts/definitions/age2
# age_group = 0-1: infant, 1-14: child, 15-24: youth, 25-64: adult, >65- senior
data_train<- data_train %>%
  mutate(age_group = case_when(Age <=1  ~ "infant",
                              Age > 1 & Age <= 14 ~ "child",
                              Age > 15 & Age <= 24 ~ "youth",
                              Age > 25 & Age <= 64 ~ "adult",
                              Age > 64  ~ "senior")
         )

colSums(is.na(data_train))
data_train <- impute_mode(data_train)
colSums(is.na(data_train))

# coerce age_group to factor type. If not changed then glm model throws warning prediction from a rank-deficient fit may be misleading
data_train$age_group<- factor(data_train$age_group)
# drop some variables
data_train$Name<- NULL
data_train$Age<- NULL

# apply the same transformation steps to data_test
data_test <- impute_median(data_test)
data_test <- impute_mode(data_test)
# look at the name variable
data_test$title<- str_extract(data_test$Name ,
                               pattern = "(Mr|Master|Mrs|Miss|Dr|Major|Countess|Rev)\\.")
# coerce title to factor type. If not changed then glm model throws warning prediction from a rank-deficient fit may be misleading
data_test$title<- factor(data_test$title)
data_test<- data_test %>%
  mutate(age_group = case_when(Age <=1  ~ "infant",
                               Age > 1 & Age <= 14 ~ "child",
                               Age > 15 & Age <= 24 ~ "youth",
                               Age > 25 & Age <= 64 ~ "adult",
                               Age > 64  ~ "senior")
  )
colSums(is.na(data_test))
data_test <- impute_mode(data_test)
colSums(is.na(data_train))

# coerce age_group to factor type. If not changed then glm model throws warning prediction from a rank-deficient fit may be misleading
data_test$age_group<- factor(data_test$age_group)
# drop some variables
data_test$Name<- NULL
data_test$Age<- NULL




# Build models again
# split the train dataset into train and test set
set.seed(2020)
index <- createDataPartition(data_train$Survived, p = 0.7, list = FALSE)
df_train <- data_train[index, ]
df_test  <- data_train[-index, ]

# recursive Partitioning/Decision Trees 
set.seed(2020)
# drop factor variables with more than 10 levels for now
fit_rpart<-caret::train(Survived ~ .,data = df_train[,-c(7,9)],
                        method = "rpart",
                        preProcess = c("scale", "center"),
                        trControl = ctrl 
                        ,metric= "ROC"
                        )

# Generalised Linear Modellig
set.seed(2020)
fit_glm<-caret::train(Survived ~ .,data = df_train[,-c(7,9)]
                      , method = "glm", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC")

# Random Forest Modellig
set.seed(2020)
fit_rf<-caret::train(Survived ~ .,data = df_train[,-c(7,9)]
                      , method = "rf", family = "binomial"
                      , preProcess = c("scale", "center")
                      , trControl = ctrl
                      , metric= "ROC")

# summarize accuracy of models
models <- resamples(list(rpart=fit_rpart, glm=fit_glm, rf=fit_rf))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_rf, df_test)
confusionMatrix(predictions, df_test$Survived) 
# Basis of feature egineering creating two new variables improved the accuracy to 89%.

# PREDICTIVE MODELLING On BALANCED DATA
# Method 1: Under Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "down")

fit_under<-caret::train(Survived ~ .,data = df_train[,-c(7,9)],
                                   method = "rf",
                                   preProcess = c("scale", "center"),
                                   trControl = ctrl 
                                   ,metric= "ROC"
                              )

# Method 2: Over Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary,
                     sampling = "up"
)

fit_over<-caret::train(Survived ~ .,data = df_train[,-c(7,9)],
                       method = "rf",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC"
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

fit_rose<-caret::train(Survived ~ .,data = df_train[,-c(7,9)],
                       method = "rf",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC"
                       )

# summarize accuracy of models
models <- resamples(list(rf_under=fit_under, rf_over=fit_over, rf_rose=fit_rose))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)


# Make Predictions using the best model on data_test
predictions <- predict(fit_over, data_test)


### Final features
colnames(df_train)
# [1] "PassengerId" "Survived"    "Pclass"      "Sex"        
# [5] "SibSp"       "Parch"       "Ticket"      "Fare"       
# [9] "Cabin"       "Embarked"    "title"       "age_group"  

# Save the solution to a dataframe with two columns: PassengerId and Survived (prediction)
solution <- data.frame(PassengerID = data_test$PassengerId, Survived = predictions)
dim(data_test)

# Write the solution to file
write.csv(solution, file = 'data/kaggle_titanic_rf_oversample_Solution.csv', row.names = F)

