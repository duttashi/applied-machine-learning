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

# look at data structure
names(covid_data)
names(data_test)

# combine the train & test data
# test data does not have two cols that are present in the train data
# to merge the two dataframes together, they must have the same number of cols
data_train <- data_train %>%
  mutate(type='train')
data_test<- data_test %>%
  mutate(ConfirmedCases = NA, Fatalities = NA, type = 'test')  %>% 
  rename(Id = ForecastId)

# combine the train & test data together
covid_data<- rbind(data_train, data_test)
# drop train & test data
rm(data_train)
rm(data_test)

# Data cleaning for combined data
# coerce multiple character vars to factor
# covid_data<- covid_data %>%
#   mutate_if(is.character, funs(factor(.)))
# replace empty factor levels with NA
# find_empty_level<- which(levels(covid_data$Province.State)=="")
# levels(covid_data$Province.State)[find_empty_level]<-"NA"
# convert date from categorical to Date format
covid_data$Date <- as.Date(covid_data$Date, format = "%Y-%m-%d")
# separate date into year, month, day format
covid_data<- covid_data %>%
  separate(Date, c("Year", "Month", "Day"), sep = "-")
# coerce Year, Month, Day from character to int
covid_data$Year<- as.integer(covid_data$Year)
covid_data$Month<- as.integer(covid_data$Month)
covid_data$Day<- as.integer(covid_data$Day)

sum(is.na(covid_data)) # missing values
colSums(is.na(covid_data))

# Supervised Feature selection
table(covid_data$Year) # year is constant
table(covid_data$Month) # 4 months data

# initial plots
covid_country <- covid_data %>% 
  filter(Country.Region %in% c('China','Italy','US','Brazil','India','France')) %>%
  filter(type == 'train')  %>% 
  group_by(Day, Country.Region) %>% 
  summarise(ConfirmedCases = sum(ConfirmedCases), death = sum(Fatalities))

ggplot(covid_country, aes(Day, ConfirmedCases))+
  geom_point(color = 'blue')+
  geom_line(color = 'blue')+
  geom_point(aes(Day, death), color = 'red')+
  facet_wrap(~ Country.Region)+
  theme_classic()

# Data Modelling

# separate the data basis of type
covid.train <- covid_data  %>% 
  filter(type == 'train')
covid.test <- covid_data  %>% 
  filter(type == 'test')

# drop vars from covid.test & covid.train
covid.test$ConfirmedCases<- NULL
covid.test$Fatalities<- NULL
covid.train$type<- NULL
covid.test$type<- NULL

str(covid.train)
str(covid.test)
table(covid.train$Year) # constant value, drop it
table(covid.test$Year) # constant value, drop it

covid.train$Year<- NULL
covid.test$Year<- NULL

sum(is.na(covid.train))
sum(is.na(covid.test))

# dummy encode the factor vars to numeric

for (f in names(covid.train)) {
  if (class(covid.train[[f]])=="character") {
    levels <- unique(c(covid.train[[f]], covid.test[[f]]))
    covid.train[[f]] <- as.integer(factor(covid.train[[f]], levels=levels))
    covid.test[[f]]  <- as.integer(factor(covid.test[[f]],  levels=levels))
  }
}

# XGBoost
library(xgboost)
str(covid.train)
# tune and run the model for ConfirmedCases
model_xbg<- xgboost(data = covid.train, 
        booster = "gblinear", 
        objective = "binary:logistic", 
        max.depth = 5, 
        nround = 2, 
        lambda = 0, 
        lambda_bias = 0, 
        alpha = 0
        )


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
print(importance) # Fatalities, Long, Lat, Id, Month, Year, Province.State, Country.Region
# plot importance
plot(importance)

## Predictive modeling for confirmed cases
# Run algorithms using 3-fold cross validation
set.seed(2020)

# Build models

# CART
fit_cart<-train(ConfirmedCases ~ Province.State+Country.Region+Lat+Long+Month+Day,data = covid.train,
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
RMSLE_1 # 4.16

#Test set predictions:
covid.test$Preds <- predict(fit_cart, newdata = covid.test)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(covid.test$Preds + 1) - 
                        log(covid.test$ConfirmedCases + 1))^2))
RMSLE_2 # NAN ?

# XGBoost
# XGBoost only works with numeric vectors.
str(covid.train)
feature.names <- names(covid.train)[2:ncol(covid.train)-1]

cat("assuming text variables are categorical & replacing them with numeric ids\n")
for (f in feature.names) {
  if (class(covid.train[[f]])=="Factor") {
    levels <- unique(c(covid.train[[f]], covid.test[[f]]))
    covid.train[[f]] <- as.integer(factor(covid.train[[f]], levels=levels))
    covid.test[[f]]  <- as.integer(factor(covid.test[[f]],  levels=levels))
  }
}
