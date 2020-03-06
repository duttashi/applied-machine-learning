# Objective: starter code for predicting flight delay for more than 15 minutes
# evaluation metric- ROC AUC
# data source: https://www.kaggle.com/c/flight-delays-fall-2018/overview/description

# clean workspace
rm(list = ls())

# load required libraries
library(tidyverse)
library(caret) # createDatapartition
library(MASS) # lda()
# read the data
df_train<- read.csv("data/kaggle_flight_delays_train.csv", header = TRUE,
                    stringsAsFactors = FALSE)
df_test<- read.csv("data/kaggle_flight_delays_test.csv", header = TRUE,
                    stringsAsFactors = FALSE)
df_smpl_submit<- read.csv("data/kaggle_flight_delays_sample_submission.csv", header = TRUE,
                    stringsAsFactors = FALSE)
head(df_train)

# observations
# remove 'c-' from month, dayofmonth, dayofweek
df_train$Month<-gsub("[c-]","", df_train$Month)
df_train$DayofMonth<-gsub("[c-]","", df_train$DayofMonth)
df_train$DayOfWeek<-gsub("[c-]","", df_train$DayOfWeek)

df_test$Month<-gsub("[c-]","", df_test$Month)
df_test$DayofMonth<-gsub("[c-]","", df_test$DayofMonth)
df_test$DayOfWeek<-gsub("[c-]","", df_test$DayOfWeek)

# convert DepTime into hour and minute format
# first ensure the time is in standard 0000 (ie 4 digit format)
df_train$DepTime<- sprintf("%04d", df_train$DepTime)
# then convert it into hour and minute format
df_train$DepTime<- format(strptime(df_train$DepTime, format="%H%M"), format = "%H:%M")
# now split the variable into departure hour and departure minute cols
df_train<- df_train %>%
  separate(DepTime, into = c("dep_hr","dep_min"), sep = ":")

# now do the same for test data
df_test$DepTime<- sprintf("%04d", df_test$DepTime)
# then convert it into hour and minute format
df_test$DepTime<- format(strptime(df_test$DepTime, format="%H%M"), format = "%H:%M")
# now split the variable into departure hour and departure minute cols
df_test<- df_test %>%
  separate(DepTime, into = c("dep_hr","dep_min"), sep = ":")

# check for missing data in training set
sum(is.na(df_train))
colSums(is.na(df_train)) # 17 missing values in dep_hr and dep_min
colSums(is.na(df_test)) # 0 missing values

# replace missing values in variabledep_hr  dep_min with median
df_train$dep_hr<- ifelse(is.na(df_train$dep_hr), median(df_train$dep_hr,na.rm = TRUE),df_train$dep_hr)
df_train$dep_min<- ifelse(is.na(df_train$dep_min), median(df_train$dep_min,na.rm = TRUE),df_train$dep_min)
#df_train$dep_delayed_15min<- ifelse(df_train$dep_delayed_15min=="Y","Yes","No")
df_train$dep_delayed_15min<- ifelse(df_train$dep_delayed_15min=="Yes","1","0")

# change data type
df_train$Month<- as.integer(df_train$Month)
df_train$DayofMonth<- as.integer(df_train$DayofMonth)
df_train$DayOfWeek<- as.integer(df_train$DayOfWeek)
df_train$dep_hr<- as.integer(df_train$dep_hr)
df_train$dep_min<- as.integer(df_train$dep_min)
df_train$Distance<- as.integer(df_train$Distance)
df_train$UniqueCarrier<- as.factor(df_train$UniqueCarrier)
df_train$Origin<- as.factor(df_train$Origin)
df_train$Dest<- as.factor(df_train$Dest)
df_train$dep_delayed_15min<- as.factor(df_train$dep_delayed_15min)
str(df_train)

# rearrange vars such that int are first followed by char
df_train<- df_train[,c(1:5,9,6:8,10)]
str(df_train)

# Stratified sampling because data is huge
set.seed(2020)
df_train_smpl<- df_train %>%
  group_by(UniqueCarrier,dep_delayed_15min) %>%
  sample_n(.,18)

# # prepare training scheme
# #control <- trainControl(method="repeatedcv", number=3, repeats=3)
# # define the control using a random forest selection function
# control <- rfeControl(functions=rfFuncs, method="cv", number=3)
# # run the RFE algorithm
# results <- rfe(df_train_smpl[,1:6], df_train_smpl[,10], sizes=c(1:6), rfeControl=control)
# 
# # train the model
# model <- train(dep_delayed_15min~., data=df_train_smpl[,c(1:6,10)], method="lvq", preProcess="scale", trControl=control)
# # estimate variable importance
# importance <- varImp(model, scale=FALSE)
# # summarize importance
# print(importance)
# # plot importance
# plot(importance)


###### PREDICTIVE MODELLING ON IMBALANCED TRAINING DATA
# Run algorithms using 3-fold cross validation
set.seed(2020)
index <- createDataPartition(df_train_smpl$dep_delayed_15min, p = 0.7, list = FALSE, times = 1)
train_data <- data.frame(df_train_smpl[index, ])
test_data  <- data.frame(df_train_smpl[-index, ])
# create caret trainControl object to control the number of cross-validations performed
ctrl <- trainControl(method = "repeatedcv",
                     number = 3,
                     # repeated 3 times
                     repeats = 3, 
                     verboseIter = FALSE, 
                     classProbs=TRUE, 
                     summaryFunction=twoClassSummary
                     )

# Metric is AUPRC which is Area Under Precision Recall Curve (PRC). Its more robust then using ROC. Accuracy and Kappa are used for balanced classes, while PRC is used for imbalanced classes
set.seed(2020)
# turning "warnings" off
options(warn=-1)
#metric <- "AUPRC"
metric <- "AUC"

# logistic regression
fit_logreg<-train(dep_delayed_15min ~., data = train_data , 
                  method='glm', 
                  trControl=ctrl,  
                  metric = metric,
                  preProc = c("center", "scale"))

# gradient boosting
fit_gbm <- train(dep_delayed_15min ~., data = train_data ,
                 method='gbm',
                 trControl=ctrl,
                 metric = metric,
                 preProc = c("center", "scale")
)

# Model summary
models <- resamples(list(logreg = fit_logreg, gbm = fit_gbm))
summary(models)
# compare models
dotplot(models)
bwplot(models)
# Make Predictions using the best model
predictions <- predict(fit_gbm, test_data) # gbm
confusionMatrix(predictions, test_data$dep_delayed_15min) # 62% accuracy, balanced accuracy # 62%
predict_res<- cbind(test_data, predictions)
# write to file
#write.csv()

