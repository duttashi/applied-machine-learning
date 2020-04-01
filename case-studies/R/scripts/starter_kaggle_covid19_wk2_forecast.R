# Challenge: While the challenge involves forecasting confirmed cases and fatalities between March 25 and April 22 by region, the primary goal isn't to produce accurate forecasts. It’s to identify factors that appear to impact the transmission rate of COVID-19.
# data source: https://www.kaggle.com/c/covid19-global-forecasting-week-1/data

# clean the workspace
rm(list = ls())
# load required libraries
library(tidyverse) 
library(caret) 

# load data
data_train<- read.csv("data/kaggle_covid19_wk2_train.csv", na.strings=c("","NA"),
                      header = TRUE,sep = ",", stringsAsFactors = FALSE)
data_test<- read.csv("data/kaggle_covid19_wk2_test.csv",na.strings=c("","NA"),
                     header = TRUE,sep = ",", stringsAsFactors = FALSE)

# look at data structure
sum(is.na(data_train)) # [1] 10816 missing values
sum(is.na(data_test)) # [1] 7267 missing values

# show variables with missing values
colSums(is.na(data_train)) # Province_State has all 10816 missing values
colSums(is.na(data_test)) # Province_State has all 7267 missing values

# Missing data imputation
library(mice)
# change province to factor else imputation will not work
data_train$Province_State<- factor(data_train$Province_State)
tempData <- mice(data_train,m=5,maxit=10,method='cart',seed=2020)
data_train_cmplt <- complete(tempData,4)
write.csv(data_train_cmplt,file = "data/kaggle_covid19_wk2_datatrain_cmplt.csv", row.names = FALSE)

data_test$Province_State<- factor(data_test$Province_State)
tempData <- mice(data_test,m=5,maxit=10,method='cart',seed=2020)
data_test_cmplt <- complete(tempData,4)
write.csv(data_test_cmplt,file = "data/kaggle_covid19_wk2_datatest_cmplt.csv", row.names = FALSE)

# # filter out the observations with missing value and save to separate data frame
# data_train_1 <- data_train %>%
#   drop_na(Province_State)
# data_test_1 <- data_test %>%
#   drop_na(Province_State)

# combine the train & test data
# test data does not have two cols that are present in the train data
# to merge the two dataframes together, they must have the same number of cols
data_train_1 <- data_train_cmplt %>%
  mutate(type='train')
data_test_1<- data_test_cmplt %>%
  mutate(ConfirmedCases = 0, Fatalities = 0, type = 'test')  %>% 
  rename(Id = ForecastId)

# combine the train & test data together
covid_data<- rbind(data_train_1, data_test_1)
table(covid_data$type)
# drop train & test data
rm(data_train)
rm(data_test)

# Data cleaning for combined data
str(covid_data)

# convert date from categorical to Date format
covid_data$Date <- as.Date(covid_data$Date, format = "%Y-%m-%d")
# separate date into year, month, day format
covid_data<- covid_data %>%
  separate(Date, c("Year", "Month", "Day"), sep = "-")
# coerce Year, Month, Day from character to int
covid_data$Year<- as.integer(covid_data$Year)
covid_data$Month<- as.integer(covid_data$Month)
covid_data$Day<- as.integer(covid_data$Day)

table(covid_data$Year) # year is constant
# remove year var
covid_data$Year<- NULL
table(covid_data$Month) # 4 months data

covid_country_ftls <- covid_data %>% 
  filter(Country_Region %in% c('China','US','Australia','Canada')) %>%
  group_by(Day, Country_Region) %>% 
  summarise(ConfirmedCases = sum(ConfirmedCases), death = sum(Fatalities))
# initial plots
ggplot(covid_country_ftls, aes(Day, ConfirmedCases))+
  geom_point(color = 'blue')+
  geom_line(color = 'blue')+
  geom_point(aes(Day, death), color = 'red')+
  facet_wrap(~ Country_Region)+
  theme_classic()

# subset data based on confirmed cases 
cntry_most_affectd<-covid_data %>%
  filter(Country_Region %in% c('China','US','Australia','Canada'))
dim(cntry_most_affectd) # 11,235 observations
table(cntry_most_affectd$type)
table(cntry_most_affectd$Country_Region)

# drop Id and Province_State
cntry_most_affectd$Province_State<- NULL

# Data Modelling
# separate the data basis of type
covid.train <- cntry_most_affectd  %>% 
  filter(type == 'train')
covid.test <- cntry_most_affectd  %>% 
  filter(type == 'test')

# drop vars from covid.test & covid.train
covid.train$type<- NULL
covid.test$type<- NULL

# dummy encode the factor vars to numeric
for (f in names(covid.train)) {
  if (class(covid.train[[f]])=="character") {
    levels <- unique(c(covid.train[[f]], covid.test[[f]]))
    covid.train[[f]] <- as.integer(factor(covid.train[[f]], levels=levels))
    covid.test[[f]]  <- as.integer(factor(covid.test[[f]],  levels=levels))
  }
}

# create caret trainControl object to control the number of cross-validations performed
ctrl <- trainControl(method = "repeatedcv"
                     , number = 3, repeats = 3
                     , verboseIter = FALSE
)
# apply rpart algorithm for detecting imp vars. Note: rpart will work for categorical & numeric vars
model <- train(ConfirmedCases~., 
               data=covid.train, method="rpart", 
               preProcess="scale", trControl=ctrl)
# estimate variable importance
importance <- varImp(model, scale=FALSE)
# summarize importance
print(importance) # Fatalities, country, month, day
# plot importance
plot(importance)

## Predictive modeling for confirmed cases
# Model 1: Predicting ConfirmedCases
# Outcome variable: ConfirmedCases
# Features:
# - Fatalities
# - country
# - Month
# - Day

# Build models
# CART
set.seed(2020)
fit_cart<-train(ConfirmedCases ~ .,
                data = covid.train,
                method = "rpart",
                preProcess = c("scale", "center"),
                trControl = ctrl
)
# Make Predictions
#Training set predictions:
covid.train$Preds<- predict(fit_cart, newdata = covid.train)
table(covid.train$Preds)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_1 <- sqrt(mean((log(covid.train$Preds + 1) - 
                        log(covid.train$ConfirmedCases + 1))^2))
RMSLE_1 # 3.71

#Test set predictions:
covid.test$Preds <- predict(fit_cart, newdata = covid.test)
table(covid.test$Preds)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(covid.test$Preds + 1) - 
                        log(covid.test$ConfirmedCases + 1))^2))
RMSLE_2 # 4.92

# Model 2: Predicting Fatalities
# Outcome variable: Fatalities
# Features:
# - country
# - Month
# - Day
set.seed(2020)
# Build models
# CART
fit_cart_1<-train(Fatalities~ Country_Region+Month+Day,
                  data = covid.train,
                  method = "rpart",
                  preProcess = c("scale", "center"),
                  trControl = ctrl
                  )
# Make Predictions
#Training set predictions:
covid.train$Preds_1<- predict(fit_cart_1, newdata = covid.train)
table(covid.train$Preds_1)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(covid.train$Preds_1 + 1) - 
                        log(covid.train$Fatalities + 1))^2))
RMSLE_2 # 1.99

#Test set predictions:
covid.test$Preds_1 <- predict(fit_cart_1, newdata = covid.test)

# create submission file
submission <- covid.test %>%
  select(Id, Preds, Preds_1)
colnames(submission) <- c("ForecastId", "ConfirmedCases", "Fatalities")
# write to disc
write.csv(submission, file = "data/kaggle_covid19_wk2_submission_2.csv", row.names = FALSE)

