# Objective: challenges you to predict the final price of each home.
# Evaluation metric # Submissions are evaluated on Root-Mean-Squared-Error (RMSE) between the logarithm of the predicted value and the logarithm of the observed sales price. (Taking logs means that errors in predicting expensive houses and cheap houses will affect the result equally.)
# Dependent variable # SalePrice
# reference # https://www.kaggle.com/c/home-data-for-ml-course/overview


# required libraries
library(tidyverse)
library(caret)
library(rpart)
library(rpart.plot)
library(corrplot)

# clean the workspace
rm(list = ls())
# read data in memory
train_data<- read.csv("data/kaggle_houseprice_train.csv",
               header=T, na.strings=c("","NA"), stringsAsFactors = FALSE)
test_data<- read.csv("data/kaggle_houseprice_test.csv",
                      header=T, na.strings=c("","NA"), stringsAsFactors = FALSE)

# EDA

# 1. Check for missing values
sum(is.na(train_data)) # 6965 missing values
colSums(is.na(train_data)) # > 80% missing values in variables PoolQC. Fence, MiscFeat
str(train_data)
table(train_data$PoolQC) # categorical
table(train_data$Fence) # categorical
table(train_data$MiscFeature) # categorical

sum(is.na(test_data)) # 7000 missing values
colSums(is.na(test_data)) # > 80% missing values in variables PoolQC. Fence, MiscFeat

# Drop some columns with 80% missing data
train_cleaned <- train_data %>%
  select(-c(Id, Alley, PoolQC, Fence, MiscFeature))
test_cleaned <- test_data %>%
  select(-c(Id, Alley, PoolQC, Fence, MiscFeature))

# Initial baseline modelling
fit <- rpart(formula = SalePrice~., data = train_cleaned, method = "anova", minbucket = 10, cp = -1)
rpart.plot(fit)
# Variable importance
fit$variable.importance

# Initial baseline prediction
predicted <- predict(fit, test_cleaned)
summary(predicted)

# create initial baseline submission file
submission <- tibble('Id' = test_data$Id, 'SalePrice' = predicted)
write_csv(submission, 'data/kaggle_houseprice_baseline_submission.csv')

# Kaggle Submission score: 22452.18249

##### Attempt # 2

# Dimensionality reduction steps for training data
# check for variables with more than 75% data is missing
miss_cols<- lapply(train_cleaned, function(col){sum(is.na(col))/length(col)})
train_cleaned<- train_cleaned[, !(names(train_cleaned) %in% names(miss_cols[lapply(miss_cols, function(x) x) > 0.75]))]  # 6 cols with more than 75% missing data
# check for variables with more than 80% values are zero
zero_cols<- lapply(train_cleaned, function(col){length(which(col==0))/length(col)})
#zero_cols<- as.data.frame(zero_cols)
train_cleaned<- train_cleaned[, !(names(train_cleaned) %in% names(zero_cols[lapply(zero_cols, function(x) x) > 0.8]))]
# remove columns where the standard derivation is zero
std_zero_col <- lapply(train_cleaned, function(col){sd(col, na.rm = TRUE)})
train_cleaned <- train_cleaned[, !(names(std_zero_col) %in% names(std_zero_col[lapply(std_zero_col, function(x) x) == 0]))] # only 1 variable with std dev is zero
# check for near zero variance cols
badCols<- nearZeroVar(train_cleaned)
names(train_cleaned[, badCols]) # 13 cols in aps_train data with near zero variance property. removing them
train_cleaned<- train_cleaned[, -badCols]

# Apply the same steps for dimensionality reduction to the test set
# check for variables with more than 75% data is missing
miss_cols<- lapply(test_cleaned, function(col){sum(is.na(col))/length(col)})
test_cleaned<- test_cleaned[, !(names(test_cleaned) %in% names(miss_cols[lapply(miss_cols, function(x) x) > 0.75]))]  # 6 cols with more than 75% missing data
# check for variables with more than 80% values are zero
zero_cols<- lapply(test_cleaned, function(col){length(which(col==0))/length(col)})
test_cleaned<- test_cleaned[, !(names(test_cleaned) %in% names(zero_cols[lapply(zero_cols, function(x) x) > 0.8]))]
# remove columns where the standard derivation is zero
std_zero_col <- lapply(test_cleaned, function(col){sd(col, na.rm = TRUE)})
test_cleaned <- test_cleaned[, !(names(std_zero_col) %in% names(std_zero_col[lapply(std_zero_col, function(x) x) == 0]))] # only 1 variable with std dev is zero
# check for near zero variance cols
badCols<- nearZeroVar(test_cleaned)
names(test_cleaned[, badCols]) # 11 cols in aps_train data with near zero variance property. removing them
test_cleaned<- test_cleaned[, -badCols]

# Modelling attempt # 2
fit <- rpart(formula = SalePrice~., data = train_cleaned, method = "anova", minbucket = 10, cp = -1)
rpart.plot(fit)
# Variable importance
fit$variable.importance

# Prediction attempt 2
predicted <- predict(fit, test_cleaned)
summary(predicted)

# create submission file
submission <- tibble('Id' = test_data$Id, 'SalePrice' = predicted)
write_csv(submission, 'data/kaggle_houseprice_submission_attempt_2.csv')
# Kaggle Submission score: 22452.18249 No change in score

##### Attempt # 3

# Merge the training and test set together
dim(train_cleaned)
dim(test_cleaned)
names(train_cleaned)
names(test_cleaned)

#df_merged<- merge(train_cleaned, test_cleaned, by="SaleType", all = TRUE)
# replace all missing values with zero
# here df contains training data and test_cleaned contains test data
train_cleaned[is.na(train_cleaned)]<-0
# rearrange the columns such that numeric and categorical vars are separated
# Reference: See this So post: https://stackoverflow.com/questions/5863097/selecting-only-numeric-columns-from-a-data-frame/5863165
nums <- names(select_if(train_cleaned, is.numeric))
cats <- names(select_if(train_cleaned, is.character))
# rearrange the vars such the numeric are first followed by categoricals
train_cleaned<- train_cleaned[,c(nums,cats)] 
train_cleaned<- train_cleaned[,c(1:27,29:55,28)] # put SalePrice as the last col
str(train_cleaned)
names(train_cleaned) # 1:27 are numeric cols
# Correlation detection & treatment
# Check for multicollinearity
cor1<- cor(train_cleaned[,c(1:27,55)])
corrplot(cor1, number.cex = .7)
hc <- findCorrelation(cor1, cutoff = 0.3)
hc <- sort(hc)
names(train_cleaned[,hc]) # 13 vars are highly correlated
train_cleaned<- train_cleaned[,-c(hc)] # removed the high correlated vars
str(train_cleaned)

###### Do the same steps for test data
# replace all missing values with zero
# here df contains training data and test_cleaned contains test data
test_cleaned[is.na(test_cleaned)]<-0
# rearrange the columns such that numeric and categorical vars are separated
# Reference: See this So post: https://stackoverflow.com/questions/5863097/selecting-only-numeric-columns-from-a-data-frame/5863165
nums <- names(select_if(test_cleaned, is.numeric))
cats <- names(select_if(test_cleaned, is.character))
# rearrange the vars such the numeric are first followed by categoricals
test_cleaned_sort<- test_cleaned[,c(nums,cats)] 
# Correlation detection & treatment for test data
# Check for multicollinearity
cor1<- cor(test_cleaned_sort[,c(1:27)])
corrplot(cor1, number.cex = .7)
hc <- findCorrelation(cor1, cutoff = 0.3)
hc <- sort(hc)
names(test_cleaned_sort[,hc]) # 13 vars are highly correlated
test_cleaned<- test_cleaned_sort[,-c(hc)] # removed the high correlated vars

# Modelling attempt # 3
fit <- rpart(formula = SalePrice~., data = train_cleaned, method = "anova", minbucket = 10, cp = -1)
rpart.plot(fit)
# Variable importance
fit$variable.importance

# Prediction attempt 3
predicted <- predict(fit, newdata = test_cleaned)
summary(predicted)

# create submission file
submission <- tibble('Id' = test_data$Id, 'SalePrice' = predicted)
write_csv(submission, 'data/kaggle_houseprice_submission_attempt_2.csv')
# Kaggle Submission score: 22452.18249 No change in score
