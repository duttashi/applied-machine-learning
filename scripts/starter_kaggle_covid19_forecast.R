# Challenge: While the challenge involves forecasting confirmed cases and fatalities between March 25 and April 22 by region, the primary goal isn't to produce accurate forecasts. It’s to identify factors that appear to impact the transmission rate of COVID-19.
# data source: https://www.kaggle.com/c/covid19-global-forecasting-week-1/data

# clean the workspace
rm(list = ls())
# load required libraries
library(tidyverse) 
library(caret) 

# load data

data_train<- read.csv("data/kaggle_covid19_train.csv", header = TRUE,sep = ",", stringsAsFactors = FALSE)
data_test<- read.csv("data/kaggle_covid19_test.csv", header = TRUE,sep = ",", stringsAsFactors = FALSE)

# Data cleaning for training set
# coerce multiple character vars to factor
data_train<- data_train %>%
  mutate_if(is.character, funs(factor(.)))
# replace empty factor levels with NA
find_empty_level<- which(levels(data_train$Province.State)=="")
levels(data_train$Province.State)[find_empty_level]<-"NA"
# convert date from categorical to Date format
data_train$Date <- as.Date(data_train$Date, format = "%Y-%m-%d")
# separate date into year, month, day format
data_train<- data_train %>%
  separate(Date, c("Year", "Month", "Day"), sep = "-")
# coerce Year, Month, Day from character to int
data_train$Year<- as.integer(data_train$Year)
data_train$Month<- as.integer(data_train$Month)
data_train$Day<- as.integer(data_train$Day)

sum(is.na(data_train)) # no missing values
sum(is.na(data_test))# no missing values

# Data cleaning for test set
# coerce multiple character vars to factor
data_test<- data_test %>%
  mutate_if(is.character, funs(factor(.)))
# replace empty factor levels with NA
find_empty_level<- which(levels(data_test$Province.State)=="")
levels(data_test$Province.State)[find_empty_level]<-"NA"
# convert date from categorical to Date format
data_test$Date <- as.Date(data_test$Date, format = "%Y-%m-%d")
# separate date into year, month, day format
data_test<- data_test %>%
  separate(Date, c("Year", "Month", "Day"), sep = "-")
# coerce Year, Month, Day from character to int
data_test$Year<- as.integer(data_test$Year)
data_test$Month<- as.integer(data_test$Month)
data_test$Day<- as.integer(data_test$Day)

# Supervised Feature selection
table(data_train$Year) # year is constant
table(data_train$Month) # 3 months data
table(data_train$Day)

str(data_train)
# create caret trainControl object to control the number of cross-validations performed
ctrl <- trainControl(method = "repeatedcv"
                     , number = 3, repeats = 3
                     , verboseIter = FALSE
                     )
# apply rpart algorithm for detecting imp vars. Note: rpart will work for categorical & numeric vars
model <- train(ConfirmedCases~., 
               data=data_train, method="rpart", 
               preProcess="scale", trControl=ctrl)
# estimate variable importance
importance <- varImp(model, scale=FALSE)
# summarize importance
print(importance) # Fatalities, Long, Lat, Id, Month, Year, Province.State, Country.Region
# plot importance
plot(importance)

## Predictive modeling for confirmed cases
# Run algorithms using 3-fold cross validation
set.seed(2020)

# Build models
str(data_train)
# CART
fit_cart<-train(ConfirmedCases ~ Province.State+Country.Region+Lat+Long+Month+Day,data = data_train,
                       method = "rpart",
                       preProcess = c("scale", "center"),
                       trControl = ctrl
                )
# Make Predictions
#Training set predictions:
data_train$Preds<- predict(fit_cart, newdata = data_train)
table(data_train$Preds)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_1 <- sqrt(mean((log(data_train$Preds + 1) - 
                        log(data_train$ConfirmedCases + 1))^2))
RMSLE_1 # 4.16

#Test set predictions:
str(data_test)
data_test$Preds <- predict(fit_cart, newdata = data_test)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(data_test$Preds + 1) - 
                        log(data_test$ConfirmedCases + 1))^2))
RMSLE_2 # NAN ?
