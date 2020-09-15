# Objective: Loan prediction problem 
# hosted at: https://datahack.analyticsvidhya.com/contest/practice-problem-loan-prediction-iii/#ProblemStatement
# Evaluation metric: Accuracy

# clean the workspace
rm(list = ls())
# required libraries
library(readr)
library(caret)
library(mlbench)
library(xgboost)

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

# Feature Importance
modelFit<-train(Loan_Status ~ .,data = data_imputd_train[,c(-1)],
                       method = "rpart")
varImp(modelFit)

varimp_data<- data_imputd_train[,c(1,3,8,10:13)]

# PREDICTIVE MODELLING On BALANCED DATA
# Method 2: Over-Sampling
set.seed(2020)
ctrl <- trainControl(method = "repeatedcv", 
                     number = 10, 
                     repeats = 10,
                     sampling = "up",
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary)

fit_over<-train(Loan_Status ~ .,data = data_imputd_train[,c(-1)],
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl, 
                       metric= "ROC",
                       tuneLength=5)
fit_over
summary(fit_over$finalModel)
# plot the model
plot(fit_over$finalModel, uniform=TRUE,
     main="Classification Tree")
text(fit_over$finalModel, use.n.=TRUE, all=TRUE, cex=.8)

# Make Predictions using the best model
predictions <- predict(fit_over, data_imputd_test)
# create a submission file
submt<- data.frame(data_imputd_test$Loan_ID, predictions)

write.table(submt,"data/av_loanpred_rpart_model.csv", 
            col.names = c("Loan_ID","Loan_Status"),
            sep = ",", row.names = FALSE)

# 67% accuracy with rpart model with all data on leaderboard
# 75% accuracy with rpart model with only important variables leaderboard

# 77% accuracy with SVM Linear model with all data on leaderboard
# 76% accuracy with SVM Linear model with only imp var data on leaderboard

# 71% accuracy using imp variables and nnet
# 74% accuracy with gbm using all data 