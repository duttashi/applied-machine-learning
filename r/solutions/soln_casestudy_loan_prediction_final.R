# Objective: Loan prediction problem 
# hosted at: https://datahack.analyticsvidhya.com/contest/practice-problem-loan-prediction-iii/#ProblemStatement
# Evaluation metric: Accuracy

# clean the workspace
rm(list = ls())
# required libraries
library(readr)
library(caret)
# read the data
data_train<- read_csv("data/av_loanpred_train.csv", na=c(" ","NA"))
data_test<-  read_csv("data/av_loanpred_test.csv", na=c(" ","NA"))

sum(is.na(data_train))
sum(is.na(data_test))
colSums(is.na(data_train))
colSums(is.na(data_test))
str(data_train)

# Initial Observations
# data has missing values
# the response variable is imbalanced
# coerce the response variable to factor type

# Missing value treatement
# impute missing values with median or mode
# reference: https://stackoverflow.com/questions/23242389/median-imputation-using-sapply  .see response by "jhoward" 
data_imputd_train<-data.frame(lapply(data_train,function(x) {
  if(is.numeric(x)) ifelse(is.na(x),median(x,na.rm=T),x) else x}))
data_imputd_test<-data.frame(lapply(data_test,function(x) {
  if(is.numeric(x)) ifelse(is.na(x),median(x,na.rm=T),x) else x}))
sum(is.na(data_imputd_test))

# convert the response variable to factor data type
data_imputd_train$Loan_Status<- factor(data_imputd_train$Loan_Status)

# Modeling the original imbalanced data
# split the train data
set.seed(42)
index <- createDataPartition(data_imputd_train$Loan_Status, p = 0.7, list = FALSE)
train_data <- data_imputd_train[index, ]
test_data  <- data_imputd_train[-index, ]

# set the control function
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary)

set.seed(2020)
fit_cart<-caret::train(Loan_Status ~ .,data = train_data[,c(-1)],
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl 
                       ,metric= "ROC")

# make prediction on imbalanced data
predictions <- predict(fit_cart, test_data[,c(-1)])
confusionMatrix(predictions, test_data$Loan_Status) # 74% on imbalanced data
final <- data.frame(actual = test_data$Loan_Status,
                    predict(fit_cart, newdata = test_data[,c(-1)], type = "prob"))
final$predict <- ifelse(final$Y > 0.5, "Yes", "No")
final$predict<- factor(final$predict)

# PREDICTIVE MODELLING On BALANCED DATA
# Method 2: Over-Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv", 
                     number = 10, 
                     repeats = 10, 
                     verboseIter = FALSE,
                     sampling = "up",
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary)

fit_cart_over<-caret::train(Loan_Status ~ .,data = data_imputd_train[,c(-1)],
                            method = "rpart",
                            preProcess = c("scale", "center"),
                            trControl = ctrl 
                            ,metric= "ROC")


# Make Predictions using the best model
predictions <- predict(fit_cart_over, data_imputd_test)
# create a submission file
submt<- data.frame(data_imputd_test$Loan_ID, predictions)

write.table(submt,"data/av_loanpred_rpart_model.csv", 
            col.names = c("Loan_ID","Loan_Status"),
            sep = ",")
