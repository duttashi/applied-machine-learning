# Competition hosted on: Kaggle
# Competition webpage: https://www.kaggle.com/c/santander-customer-transaction-prediction
# Competition Objective: To identify which customers will make a specific transaction in the future, irrespective of the amount of money transacted. 
# Evaluation metric: Area under the ROC curve
# Submission file: For each Id in the test set, you must make a binary prediction of the target variable. The file should contain a header like;
# ID_code,target
# test_0,0
# test_1,1
# test_2,0

# clean the workspace
rm(list = ls())

# load the required libraries
library(data.table)
library(xgboost)

# load the data
train = fread("data/santander-train.csv")
test = fread("data/santander-test.csv")
#sub = fread("data/santander-sample_submission.csv")

# EDA
dim(train)
dim(test)
setdiff(colnames(train), colnames(test)) 

# save the train target variable
train_target<- train$target
# drop the variables: ID_code, target from train/test set
train <- train[, !c("target", "ID_code"), with = F]
test <- test[, !c("ID_code"), with = F]


# preparing XGB matrix
dtrain <- xgb.DMatrix(data = as.matrix(train), label = as.matrix(train_target))
# parameters
params <- list(booster = "gbtree",
               objective = "binary:logistic",
               eta=0.02,
               #gamma=80,
               max_depth=2,
               min_child_weight=1, 
               subsample=0.5,
               colsample_bytree=0.1,
               scale_pos_weight = round(sum(!train_target) / sum(train_target), 2))
# CV
set.seed(2019)
xgbcv <- xgb.cv(params = params, 
                data = dtrain, 
                nrounds = 100, 
                nfold = 5,
                showsd = F, 
                stratified = T, 
                print_every_n = 20, 
                early_stopping_rounds = 10, 
                maximize = T,
                metrics = "auc")

cat(paste("Best iteration:", xgbcv$best_iteration))

# train final model
set.seed(123)
xgb_model <- xgb.train(
  params = params, 
  data = dtrain, 
  nrounds = xgbcv$best_iteration, 
  print_every_n = 20, 
  maximize = T,
  eval_metric = "auc")

#view variable importance plot
imp_mat <- xgb.importance(feature_names = colnames(train), model = xgb_model)
xgb.plot.importance(importance_matrix = imp_mat[1:30])

# make predictions
pred_sub <- predict(xgb_model, newdata=as.matrix(testX), type="response")
submission <- read.csv("data/santander_submission-1.csv")
submission$target <- pred_sub
write.csv(submission, file="santander_submission_XgBoost.csv", row.names=F)
