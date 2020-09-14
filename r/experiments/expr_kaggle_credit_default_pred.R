# Data source: Kaggle Home Loan Default prediction
# Source url: https://www.kaggle.com/c/home-credit-default-risk/overview/description
# Competition type: binary classification
# target/response variable to predict: sig_id
# evaluation metric: AUROC
# challenge aim: 

# clean the worspace
rm(list = ls())

# load required libraries
library(readr)
library(plyr) # for revalue()
library(caret)
library(mice)
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

# EDA
# coerce target variable to factor
table(train$TARGET)
train$TARGET<- factor(train$TARGET)
str(table(train$TARGET))
# recode target variable values
# as per data dictionary, 0=paid loan, 1= not paid loan
train$TARGET<- revalue(train$TARGET, c("0"="paid_loan",
                                       "1"="not_paid_loan")
                       )

# FEATURE SELECTION

# 1. Find columns with a missing fraction greater than a specified threshold
# Deleting columns from a data.frame where NA is more than 15% of the column length
# reference: https://stackoverflow.com/questions/11821303/deleting-columns-from-a-data-frame-where-na-is-more-than-15-of-the-column-lengt
train <- train[, colMeans(is.na(train)) <=.15]

# 2. Remove features with zero variance
badCols<- nearZeroVar(train)
train<- train[,-badCols]

# 3. Rearrange character and numeric vars
# separate character and numeric cols apart
charcols <- colnames(train[,sapply(train, is.character)])
numcols <- colnames(train[, sapply(train, is.numeric)])
factorcols <- colnames(train[, sapply(train, is.factor)])
# rearrange cols such that numeric cols are first followed by character cols
train<- train[,c(numcols,charcols,factorcols)] # character cols begins from index 36

# Impute missing values for numeric variables
train<-data.frame(lapply(train,function(x) {
  if(is.numeric(x)) ifelse(is.na(x),median(x,na.rm=T),x) else x}))
# drop the lone missing categorical col name_tye_suite
train$NAME_TYPE_SUITE<- NULL

# 4. Find collinear features (works only for numeric features) as identified by a correlation coefficient greater than a specified value
str(train)
train_corr = cor(train[,c(1:34)])
hc = findCorrelation(train_corr, cutoff=0.75) # find vars that are 75% correlated 
hc = sort(hc)
colnames(train[,hc])
train = train[,-c(hc)]
colSums(is.na(train))

# write clearn train data to disk
write.csv(train, file = "data/kag_hln_application_train_clean.csv")
#################################

# Model building on imbalanced dataset
# split the data into train and test
set.seed(2020)
index <- createDataPartition(train$TARGET, p = 0.7, list = FALSE)
train_data <- train[index, ]
test_data  <- train[-index, ]
ctrl <- trainControl(method = "repeatedcv"
                     , number = 10, repeats = 10
                     , verboseIter = FALSE
                     , classProbs=TRUE, 
                     summaryFunction=twoClassSummary
)
# Build models
# # CART
# set.seed(2020)
# 
# fit_cart<-caret::train(TARGET ~ .,data = train_data,
#                        method = "rpart",
#                        preProcess = c("scale", "center"),
#                        trControl = ctrl 
#                        ,metric= "ROC"
# )
# # kNN
# set.seed(2020)
# 
# fit_knn<-caret::train(TARGET ~ .,data = train_data,
#                       method = "knn",
#                       preProcess = c("scale", "center"),
#                       trControl = ctrl 
#                       , metric= "ROC")
# 
# # # Logistic Regression
# # set.seed(2020)
# # 
# # fit_glm<-caret::train(TARGET ~ .,data = train_data
# #                       , method = "glm", family = "binomial"
# #                       , preProcess = c("scale", "center")
# #                       , trControl = ctrl
# #                       , metric= "ROC")

# Support Vector Machine
fit_svm<- caret::train(TARGET ~ .,data = train_data,
                       method = "svmLinear",
                       preProcess = c("scale", "center"),
                       trControl = ctrl)
# summarize accuracy of models
models <- resamples(list(cart=fit_cart, knn=fit_knn, glm=fit_glm))
summary(models)
# compare accuracy of models
dotplot(models)
bwplot(models)

# Make Predictions using the best model
predictions <- predict(fit_glm, test_data)
confusionMatrix(predictions, test_data$TARGET) # 85% accuracy with kappa at 0.63


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

fit_under<-caret::train(TARGET ~ .,data = train_data,
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

fit_over<-caret::train(TARGET ~ .,data = train_data,
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

fit_rose<-caret::train(TARGET ~ .,data = train_data
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
confusionMatrix(predictions, test_data$TARGET) # 98% accuracy on balanced under sampled logistic regression model

