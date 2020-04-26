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
  mutate(ConfirmedCases = 0, Fatalities = 0, type = 'test')  %>% 
  rename(Id = ForecastId)

# combine the train & test data together
covid_data<- rbind(data_train, data_test)
# drop train & test data
rm(data_train)
rm(data_test)

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

sum(is.na(covid_data)) # 0 missing values

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
covid.train$type<- NULL
covid.test$type<- NULL
covid.train$Year<- NULL # constant value, drop it
covid.test$Year<- NULL # constant value, drop it

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
print(importance) # Fatalities, Long, Lat, Id, Month, Year, Province.State, Country.Region
# plot importance
plot(importance)

## Predictive modeling for confirmed cases
# Model 1: Predicting ConfirmedCases
# Outcome variable: ConfirmedCases
# Features:
#   - Province.State
# - Country.Region
# - Lat
# - Long
# - Day

set.seed(2020)
# Build models
# CART
fit_cart<-train(ConfirmedCases ~ Fatalities+Country.Region+Lat+Long+Month+Day,
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
RMSLE_1 # 3.81

#Test set predictions:
covid.test$Preds <- predict(fit_cart, newdata = covid.test)
table(covid.test$Preds)
# Evaluation: root-mean square logarithmic error on training data
RMSLE_2 <- sqrt(mean((log(covid.test$Preds + 1) - 
                        log(covid.test$ConfirmedCases + 1))^2))
RMSLE_2 # 4.48

# Model 2: Predicting Fatalities
# Outcome variable: Fatalities
# Features:
#   - Province.State
# - Country.Region
# - Lat
# - Long
# - Day
set.seed(2020)
# Build models
# CART
fit_cart_1<-train(Fatalities~Country.Region+Lat+Long+Month+Day,
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
RMSLE_2 # 1.56

#Test set predictions:
covid.test$Preds_1 <- predict(fit_cart_1, newdata = covid.test)

# create submission file
submission <- covid.test %>%
  select(Id, Preds, Preds_1)
colnames(submission) <- c("ForecastId", "ConfirmedCases", "Fatalities")
# write to disc
write.csv(submission, file = "data/kaggle_covid19_submission_1.csv", row.names = FALSE)

##### XGBOOST Model
library(xgboost)

# xgboost does not accept dataframe. So coerce dataframe to xgboost matrix
target<- covid.train$ConfirmedCases
data_train_xgb<- xgb.DMatrix(data=as.matrix(covid.train),label=target, missing=0)
data_test_xgb <- xgb.DMatrix(data=as.matrix(covid.test), missing=0)

# Set xgboost parameters. These are not necessarily the optimal parameters.
# Further grid tuning is needed. 
str(covid.train)
y <- covid.train$ConfirmedCases
xgb <- xgboost(data = data.matrix(covid.train[,-8]), 
               label = y, 
               eta = 0.1,
               max_depth = 15, 
               nround=25, 
               subsample = 0.5,
               colsample_bytree = 0.5,
               eval_metric = "merror",
               objective = "multi:softprob",
               num_class = 12,
               nthread = 3
)
covid.train$ConfirmedCases
