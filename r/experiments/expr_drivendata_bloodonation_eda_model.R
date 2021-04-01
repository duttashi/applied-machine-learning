################################################################################
##     LOADING THE DATA
################################################################################

## Warm Up: Predict Blood Donations
## Project hosted by DRIVENDATA
## Author : Ashish
## website: https://www.drivendata.org/competitions/2/warm-up-predict-blood-donations/
## Predict if the donor will give in March 2007
## The goal is to predict the last column, whether he/she donated blood in March 2007.

# clean the workspace
rm(list = ls())

# required libraries
library(dplyr) # for mutate()
library(caret)
## Loading the files containing the data and variables description :

url_train <- "https://archive.ics.uci.edu/ml/machine-learning-databases/blood-transfusion/transfusion.data"
url_names <- "https://archive.ics.uci.edu/ml/machine-learning-databases/blood-transfusion/transfusion.names"
url_test <- "https://s3.amazonaws.com/drivendata/data/2/public/5c9fa979-5a84-45d6-93b9-543d1a0efc41.csv"

if (!file.exists("data/train.csv") | !file.exists("data/test.csv") | !file.exists("data/variables.txt")) {
  download.file(url_train, destfile="data/ddbd_train.csv", method="curl")
  download.file(url_names, destfile="data/ddbd_variables.txt", method="curl")
  download.file(url_test, destfile="data/ddbd_test.csv", method="curl")}
train <- read.csv("data/ddbd_train.csv")
test <- read.csv("data/ddbd_test.csv")


## Changing variable names

names(train) <- c("since_last", "donations", "total_given", 
                  "since_first", "march2007")
names(test) <- c("index", "since_last", "donations", 
                 "total_given", "since_first")


## Changing variable types

train <- mutate(train, march2007=as.factor(ifelse(march2007==0, "No", "Yes")),
                donations=as.numeric(donations),
                total_given=as.numeric(total_given))

test <- mutate(test, donations=as.numeric(donations), 
               total_given=as.numeric(total_given))


## Cleaning the workspace
rm(url_train); rm(url_names); rm(url_test)

## Defining some transformations 
my_log <- function(x) {x <- ifelse(x==0, log(x+1e-5)+1, log(x)+1)}

my_norm <- function(x) {x <- (x-mean(x))/sd(x)}

my_boxcox <- function(x) {
  if(sum(x==0)!=0) {x <- x+1e-6} ## Adding a small value to avoid zeros
  bc <- BoxCoxTrans(x)
  L <- bc$lambda
  if(L!=0) {x <- (x^L-1)/L}
  if(L==0) {x <- log(x)}
  return(x)
}

# Feature engineering
## Creating new variables and removing total blood quantity 
train <- mutate(train,
                ## Avg. nb. of donations/months :
                rate=donations/since_first,
                
                ## Fidelity : if this number is small, it indicates that the 
                ## subject has made a lot of donations, including recent ones.
                fidelity=since_last/donations,
                
                ## fiability : if someone comes every 3 months in average and 
                ## came for the last time 3 months ago, he is likely to come 
                ## in March 2007. Then this variable is close to 0. 
                fiability=1/rate-since_last, 
                
                ## A value close to 1 indicates a person who has probably 
                ## given up donating blood.       
                has_stopped=since_last/since_first) 


## Removing redundant variable
train <- train[, -3]

## Reordering the variables (just for clarity)
train <- train[, c(1:3, 5:8, 4)]

## Reducing skewness and normalizing the different variables
train[, c(1, 2, 4, 5)] <- lapply(train[, c(1, 2, 4, 5)], my_boxcox)
train[, -8] <- lapply(train[, -8], my_norm)

## Partitioning the train set to create a validation set
index <- createDataPartition(y=train$march2007, p=0.7, list=FALSE)
train <- train[index, ]
validation <- train[-index, ]

## Performing all the same tranformations on the test dataset
test <- mutate(test, rate=donations/since_first,
               fidelity=since_last/donations,
               fiability=1/rate-since_last, 
               has_stopped=since_last/since_first)

X <- test$index
test <- test[, -c(1, 4)]
test[, c(1, 2, 4, 5)] <- lapply(test[, c(1, 2, 4, 5)], my_boxcox)
test[, names(test)] <- lapply(test[, names(test)], my_norm)

## Cross-validation 
tc <- trainControl(method="repeatedcv", number=10, repeats=10,
                   classProbs=TRUE, summaryFunction=mnLogLoss)
## Tuning grids
gbmGrid <- expand.grid(n.trees=500,
                       interaction.depth=2,
                       shrinkage=0.005,
                       n.minobsinnode=10)

nnetGrid <- expand.grid(.decay=c(0.1, 0.5), .size=c(3, 4, 5))

svmGrid <- expand.grid(sigma=c(0.5),
                       C=c(0.3))

adaGrid <- expand.grid(iter=100, maxdepth=3, 
                       nu=0.05)
## Models 
model1 <- train(march2007 ~., train, preProcess=c("pca"), method='gbm', 
                metric="logLoss", maximize=FALSE, trControl=tc,
                verbose=FALSE, tuneGrid=gbmGrid)  

model2 <- train(march2007 ~., train, preProcess=c("pca"), method='ada',
                metric="logLoss", maximize=FALSE, tuneGrid=adaGrid,
                trControl=tc) 

model3 <- train(march2007 ~., train, preProcess=c("pca"), method='svmRadial',
                metric="logLoss", maximize=FALSE, trControl=tc,
                tuneGrid=svmGrid) 

model4 <- train(march2007 ~., train, preProcess=c("pca"), method="nnet", 
                tuneGrid=nnetGrid, maxit=1000,
                trControl=tc, metric="logLoss") 

model5 <- train(march2007 ~., train, preProcess=c("pca"), method="gamSpline",
                trControl=tc, metric="logLoss") 

## Combining models
pred1V <- predict(model1, train, "prob")
pred2V <- predict(model2, train, "prob")
pred3V <- predict(model3, train, "prob")
pred4V <- predict(model4, train, "prob")
pred5V <- predict(model5, train, "prob")

combined.data <- data.frame(pred1=pred1V, pred2=pred2V, pred3=pred3V, 
                            pred4=pred4V, pred5=pred5V, 
                            march2007=train$march2007)

gbmGrid <- expand.grid(n.trees=500, interaction.depth=3,
                       shrinkage=0.01, n.minobsinnode=10)

combined.model <- train(march2007 ~., combined.data, method='gbm', 
                        metric="logLoss", maximize=FALSE, trControl=tc)

combined.result <- predict(combined.model, combined.data, "prob")
combined.result$obs <- train$march2007
mnLogLoss(combined.result, lev=levels(combined.result$obs))

## Validation
pred1V <- predict(model1, validation, "prob")
pred2V <- predict(model2, validation, "prob")
pred3V <- predict(model3, validation, "prob")
pred4V <- predict(model4, validation, "prob")
pred5V <- predict(model5, validation, "prob")

combined.data <- data.frame(pred1=pred1V, pred2=pred2V, pred3=pred3V, 
                            pred4=pred4V, pred5=pred5V,
                            march2007=validation$march2007)

combined.result <- predict(combined.model, combined.data, "prob")
combined.result$obs <- validation$march2007
mnLogLoss(combined.result, lev=levels(combined.result$obs)) ## logloss 0.33

## Predicting on test cases
pred1V <- predict(model1, test, "prob")
pred2V <- predict(model2, test, "prob")
pred3V <- predict(model3, test, "prob")
pred4V <- predict(model4, test, "prob")
pred5V <- predict(model5, test, "prob")

combined.data <- data.frame(pred1=pred1V, pred2=pred2V, 
                            pred3=pred3V, pred4=pred4V, pred5=pred5V)
combined.result <- predict(combined.model, combined.data, "prob")

result <- data.frame(X=X, combined.result=combined.result$Yes)
names(result) <- c("", "Made Donation in March 2007")

## Writing the results in a file
write.table(result, file='data/ddbd_result.csv', 
            row.name=FALSE, sep=",") 
