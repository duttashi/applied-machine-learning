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
library(caret)
library(xgboost)
library(lightgbm)
library(pROC)

# load the data
train = fread("data/santander-train.csv")
test = fread("data/santander-test.csv")
sub = fread("data/santander-sample_submission.csv")

# EDA
dim(train)
dim(test)
setdiff(colnames(train), colnames(test)) 
head(train) 
head(test)
head(sub) 

identical(sub$ID_code , test$ID_code)

train$ID_code = NULL
test$ID_code = NULL

target = train$target
summary(target)
table(target)

train$target = NULL
nrounds = 5
set.seed(1234)
folds = createFolds(factor(target), k = 5, list = FALSE)
tefinal = data.matrix(test)

dev.result <-  rep(0, nrow(train)) 
pred_te <- rep(0, nrow(test))

for (this.round in 1:nrounds){      
  valid <- c(1:length(target)) [folds == this.round]
  dev <- c(1:length(target)) [folds != this.round]
  
  dtrain<- xgb.DMatrix(data= as.matrix(train[dev,]), 
                       label= target[dev])
  #weight = w[dev])
  dvalid <- xgb.DMatrix(data= as.matrix(train[valid,]) , 
                        label= target[valid])
  valids <- list(val = dvalid)
  #### parameters are far from being optimal ####  
  param = list(objective = "binary:logistic", 
               eval_metric = "auc",
               max_depth = 4,
               eta = 0.025,
               gamma = 5,
               subsample = 0.7,   
               colsample_bytree = 0.7,
               min_child_weight = 50,  
               colsample_bylevel = 0.7,
               lambda = 1, 
               alpha = 0,
               booster = "gbtree",
               silent = 0
  ) 
  model<- xgb.train(data = dtrain,
                    params= param, 
                    nrounds = 10000, 
                    verbose = T, 
                    list(val1=dtrain , val2 = dvalid) ,       
                    early_stopping_rounds = 50 , 
                    print_every_n = 2000,
                    maximize = T
  )
  pred = predict(model,as.matrix(train[valid,]))
  dev.result[valid] = pred  
  pred_test  = predict(model,tefinal)
  pred_te = pred_te +pred_test
}

# xgboost CV score
auc(target,dev.result)
pred_test = pred_te/nrounds

pred_test_xgb = pred_test
oof_xgb = dev.result

dev.result <-  rep(0, nrow(train)) 
pred_te <- rep(0, nrow(test))

for (this.round in 1:nrounds){      
  valid <- c(1:length(target)) [folds == this.round]
  dev <- c(1:length(target)) [folds != this.round]
  
  dtrain<- lgb.Dataset(data= as.matrix(train[dev,]), 
                       label= target[dev])
  #weight = w[dev])
  dvalid <- lgb.Dataset(data= as.matrix(train[valid,]) , 
                        label= target[valid])
  valids <- list(val = dvalid)
  #### parameters are far from being optimal ####  
  p <- list(boosting_type = "gbdt", 
            objective = "binary",
            metric = "auc",  
            learning_rate = 0.025, 
            max_depth = 6,
            num_leaves = 20,
            sub_feature = 0.7, 
            sub_row = 0.7, 
            bagging_freq = 1,
            lambda_l1 = 5, 
            lambda_l2 = 5
  )
  
  model<- lgb.train(data = dtrain,
                    params= p, 
                    nrounds=10000, 
                    valids = list(val1=dtrain , val2 = dvalid), #,valids,
                    metric="auc",
                    obj = "binary",
                    eval_freq = 1000, 
                    early_stopping_rounds=50
  )
  
  pred = predict(model,as.matrix(train[valid,]))
  dev.result[valid] = pred  
  pred_test  = predict(model,tefinal)
  pred_te = pred_te +pred_test
}

# lgbm cv score
auc(target,dev.result)
pred_test = pred_te/nrounds

pred_test_lgb = pred_test
oof_lgb = dev.result

# CV score of the basic average
auc(target,(oof_xgb + oof_lgb)/2)
cor(oof_xgb , oof_lgb) ; cor(pred_test_xgb , pred_test_lgb)

oof_data = data.frame(target , oof_xgb, oof_lgb)
colnames(oof_data)[2] = "xgb"
colnames(oof_data)[3] = "lgb"

pred_data = data.frame(pred_test_xgb , pred_test_lgb)
colnames(pred_data)[1] = "xgb"
colnames(pred_data)[2] = "lgb"

lr = glm(target~., data=oof_data, family=binomial)
summary(lr)

auc(target , predict(lr, newdata=oof_data, type="response"))
pred_stack = predict(lr, newdata=pred_data, type="response")
cor(pred_stack , pred_test_lgb) ; cor(pred_stack , pred_test_xgb)

sub$target = pred_stack #(pred_test_xgb + pred_test_lgb)/2
head(sub)
fwrite(sub , "toy_sub.csv")

