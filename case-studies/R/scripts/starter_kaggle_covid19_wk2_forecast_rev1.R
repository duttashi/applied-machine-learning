# clean the workspace
rm(list = ls())
# load required libraries
library(tidyverse) 
library(caret)
library(mice)

# load data
data_train<- read.csv("data/kaggle_covid19_wk2_train.csv", na.strings=c("","NA"),
                      header = TRUE,sep = ",", stringsAsFactors = FALSE)
data_test<- read.csv("data/kaggle_covid19_wk2_test.csv",na.strings=c("","NA"),
                     header = TRUE,sep = ",", stringsAsFactors = FALSE)

# show variables with missing values
colSums(is.na(data_train)) # Province_State has all 10816 missing values
colSums(is.na(data_test)) # Province_State has all 7267 missing values

# change province to factor else imputation will not work
data_train$Province_State<- factor(data_train$Province_State)
tempData <- mice(data_train,m=5,maxit=10,method='cart',seed=2020)
data_train_cmplt <- complete(tempData,4)

data_test$Province_State<- factor(data_test$Province_State)
tempData <- mice(data_test,m=5,maxit=10,method='cart',seed=2020)
data_test_cmplt <- complete(tempData,4)

# combine the train & test data
# test data does not have two cols that are present in the train data
# to merge the two dataframes together, they must have the same number of cols
data_train <- data_train_cmplt %>%
  mutate(type='train')
data_test<- data_test_cmplt %>%
  mutate(ConfirmedCases = 0, Fatalities = 0, type = 'test')  %>% 
  rename(Id = ForecastId)

# combine the train & test data together
covid_data<- rbind(data_train, data_test)

# Data cleaning for combined data
# convert date from categorical to Date format
covid_data$Date <- as.Date(covid_data$Date, format = "%Y-%m-%d")
# separate date into year, month, day format
covid_data<- covid_data %>%
  separate(Date, c("Year", "Month", "Day"), sep = "-")
# coerce Year, Month, Day from character to int
covid_data$Year<- as.integer(covid_data$Year)
covid_data$Month<- as.integer(covid_data$Month)
covid_data$Day<- as.integer(covid_data$Day)

# coerce the Province_state var to char
covid_data$Province_State<- as.character(covid_data$Province_State)
str(covid_data)
table(covid_data$Year) # year is constant
# remove year var
covid_data$Year<- NULL
table(covid_data$Month) # 4 months data

# separate the data basis of type
covid_data_train <- covid_data  %>% 
  filter(type == 'train')
covid_data_test <- covid_data  %>% 
  filter(type == 'test')

# dummy encode the factor vars to numeric
for (f in names(covid_data_train)) {
  if (class(covid_data_train[[f]])=="character") {
    levels <- unique(c(covid_data_train[[f]], covid_data_test[[f]]))
    covid_data_train[[f]] <- as.integer(factor(covid_data_train[[f]], levels=levels))
    covid_data_test[[f]]  <- as.integer(factor(covid_data_test[[f]],  levels=levels))
  }
}

str(covid_data_train)
str(covid_data_test)
# write clean data to disc
write.csv(covid_data,file = "data/kaggle_covid19_wk2_cleandata.csv", row.names = FALSE)

# drop redundant dataframes
rm(tempData)
rm(data_test)
rm(data_train)
rm(data_test_cmplt)
rm(data_train_cmplt)
rm(covid_data)
# drop type var 
covid_data_test$type<-NULL
covid_data_train$type<-NULL

##### PREDICTIVE MODELLING
# create caret trainControl object to control the number of cross-validations performed
ctrl <- trainControl(method = "repeatedcv"
                     , number = 3, repeats = 3
                     , verboseIter = FALSE
                     )
# apply rpart algorithm for detecting imp vars. Note: rpart will work for categorical & numeric vars
model <- train(ConfirmedCases~., 
               data=covid_data_train, method="rpart", 
               preProcess="scale", trControl=ctrl)
# estimate variable importance
importance <- varImp(model, scale=FALSE)
# summarize importance
print(importance) # Fatalities, country, month, province
# plot importance
plot(importance)

## Predictive modeling for confirmed cases
# Model 1: Predicting ConfirmedCases
# Outcome variable: ConfirmedCases
# Features:
# - Fatalities
# - country
# - Month
# - province
# Build models
# CART
set.seed(2020)
fit_cart<-train(ConfirmedCases ~ Fatalities+Month+Country_Region+Province_State,
                data = covid_data_train,
                method = "rpart",
                preProcess = c("scale", "center"),
                trControl = ctrl
                )
# Make Predictions
#Training set predictions:
covid_data_train$Preds<- predict(fit_cart, newdata = covid_data_train)
table(covid_data_train$Preds)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_1 <- sqrt(mean((log(covid_data_train$Preds + 1) - 
                        log(covid_data_train$ConfirmedCases + 1))^2))
RMSLE_1 # 3.73

#Test set predictions:
covid_data_test$Preds <- predict(fit_cart, newdata = covid_data_test)
table(covid_data_test$Preds)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(covid_data_test$Preds + 1) - 
                        log(covid_data_test$ConfirmedCases + 1))^2))
RMSLE_2 # 4.48

# Model 2: Predicting Fatalities
# Outcome variable: Fatalities
# Features:
# - country
# - Month
# - Day
# - Province
set.seed(2020)
# Build models
# CART
fit_cart_1<-train(Fatalities~ Month+Country_Region+Province_State,
                  data = covid_data_train,
                  method = "rpart",
                  preProcess = c("scale", "center"),
                  trControl = ctrl
                  )
# Make Predictions
#Training set predictions:
covid_data_train$Preds_1<- predict(fit_cart_1, newdata = covid_data_train)
table(covid_data_train$Preds_1)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(covid_data_train$Preds_1 + 1) - 
                        log(covid_data_train$Fatalities + 1))^2))
RMSLE_2 # 1.14

#Test set predictions:
covid_data_test$Preds_1 <- predict(fit_cart_1, newdata = covid_data_test)

# create submission file
submission <- covid_data_test %>%
  select(Id, Preds, Preds_1)
colnames(submission) <- c("ForecastId", "ConfirmedCases", "Fatalities")
# write to disc
write.csv(submission, file = "data/kaggle_covid19_wk2_submission_2.csv", row.names = FALSE)
