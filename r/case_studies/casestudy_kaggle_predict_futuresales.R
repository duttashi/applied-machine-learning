# Objective: starter code for predicting future sales
# evaluation metric- RMSE
# data source: https://www.kaggle.com/c/competitive-data-science-predict-future-sales



# sales data for year 2020 only
# load required libraries
library(dplyr)
library(ggplot2)
library(lubridate)
library(tidyverse)

# load the required data
df_train<- read.csv("data/kaggle_predict_futuresales_train.csv", header = TRUE,
                    stringsAsFactors = FALSE)
df_test<- read.csv("data/kaggle_predict_futuresales_test.csv", header = TRUE,
                    stringsAsFactors = FALSE)
df_items<- read.csv("data/kaggle_predict_futuresales_items.csv", header = TRUE,
                    stringsAsFactors = FALSE)
# peek at the data
glimpse(df_train)
glimpse(df_test)
glimpse(df_items)

# merge df_items with df_train
df_train<- merge(df_train, df_items[,c("item_id", "item_category_id")], by = "item_id", all.x = T)
sum(is.na(df_train)) # no missing values

## Starter Linear Regression Model: to get a baseline accuracy ####
# baseline accuracy (kaggle for submission entry#1): 1.55635
linear_model = lm(formula = item_cnt_day ~ shop_id + item_id,
                  data = df_train) 
result = predict(linear_model, df_test[,c("shop_id","item_id")]) 
submission =  data.frame(ID = df_test$ID,item_cnt_month = result)
head(submission)
write.csv(submission, file = "data/kaggle_predict_futuresales_sub1.csv", row.names = F)

# EDA

# data cleaning
# initial observations
# In df_train data: split date into day, month, year cols

# convert to date format
df_train$date<- as.Date(df_train$date, format = "%d.%m.%y")
df<- df_train
# split into 3 cols
library(lubridate)
df$year <- year(ymd(df$date))
df$month <- month(ymd(df$date)) 
df$day <- day(ymd(df$date))


# drop the original date col
df$date<- NULL
table(df$year) # drop the col as it got zero variance
df$year<- NULL
table(df$month)
table(df$shop_id) # the shop ids ate from 0-59
# change data type of cols
str(df)
write.csv(df, file = "data/kaggle_predict_futuresales_clean.csv", row.names = F)

# read the clean data
df<- read.csv(file = "data/kaggle_predict_futuresales_clean.csv",
              header = TRUE, sep = ",")
str(df)
# outlier detection 
# check item price
df %>%
  #ggplot(aes(x=month))+
  ggplot(aes(x=item_price, y=month))+
  geom_boxplot()+
  #geom_line()+
  theme_bw()+
  theme(panel.border = element_rect(colour = "black", fill=NA, size=1))
summary(df$item_price)

# visualize outliers 
df%>%
  filter(item_price<699) %>%
  ggplot(aes(x=month, y=item_price))+
  geom_boxplot(outlier.colour = "red")+
  theme_bw()

# subset data based on boxplot shown above 
df.2<- df%>%
  filter(item_price<699) # item price <699 has no outliers for any of the months

## Linear Regression Model on cleaned all outlier removed subset data ####
# Accuracy (kaggle for submission entry#2): 1.53613
# Advanced 2 places on the leaderboard!
# The submission with outliers removed from item price, scored 1.53613, which is an improvement of your previous score of 1.54073. Great job!
# Learning: a complete outlier removal improves the score

names(df.1)
linear_model = lm(formula = item_cnt_day ~ shop_id + item_id,
                  data = df.2) 
result = predict(linear_model, df_test[,c("shop_id","item_id")]) 
submission =  data.frame(ID = df_test$ID,item_cnt_month = result)
head(submission)
write.csv(submission, file = "data/kaggle_predict_futuresales_sub3.csv", row.names = F)

# write the clean outlier removed dataset to disc
write.csv(df.2, file = "data/kaggle_predict_futuresales_clean.csv", row.names = F)

###### GBM model
# read the clean data
df<- read.csv(file = "data/kaggle_predict_futuresales_clean.csv",
              header = TRUE, sep = ",")
str(df)
# coerce to categorical
df$month<- as.factor(df$month)
df$day<- as.factor(df$day)
df$item_category_id<- as.factor(df$item_category_id)

library(gbm)
gbm_model  =  gbm(item_cnt_day ~ shop_id + item_id,
                  data = df,
                  shrinkage = 0.01,
                  distribution = "gaussian",
                  n.trees = 1000,
                  interaction.depth = 5, 
                  bag.fraction = 0.5,
                  train.fraction = 0.8,
                  # cv.folds = 5,
                  n.cores = -1,
                  verbose = T)
result = predict(gbm_model,newdata = df_test[,c("shop_id","item_id")], n.trees = 1000)
submission = data.frame(ID = df_test$ID, 
                  item_cnt_month =  result)
write.csv(submission, "kaggle_predict_futuresales_sub4.csv", row.names = F)

# You advanced 132 places on the leaderboard!
# Your submission scored 1.46679, which is an improvement of your previous score of 1.53613.

# visuals
library(magrittr)
library(ggplot2)
library(dplyr)
str(df)
df %>%
  group_by(shop_id) %>%
  summarise(total_sales = sum(item_cnt_day)) %>%
  arrange(desc(total_sales))%>%
  head(15)%>%
  ggplot(aes(x = reorder(as.factor(shop_id), total_sales), y = total_sales,fill=as.factor(shop_id))) +
  geom_bar(stat = 'identity') + 
  theme_bw()+
  labs(y = 'Total unit sales', x = 'Stores', title = 'Total Sales by Store') +
  coord_flip()

## store code 31 dominating more in sales contribution, followed by 25,54 and 28  

##Visualization sales trend by month by day
df %>%
  group_by(day) %>%
  summarise(total_sales = sum(item_cnt_day)) %>%
  ggplot(aes(x = as.factor(day), y = total_sales, fill =day)) +
  geom_bar(stat = 'identity') + 
  theme_bw()+
  labs(y = 'Total unit sales', x = 'Day', title = 'Total Sales by Days') 

############
library(xgboost)
library(caret)
set.seed(2020)
# Set up repeated k-fold cross-validation
train.control <- trainControl(method = "cv", number = 5)

# Stepwise regression
# http://www.sthda.com/english/articles/37-model-selection-essentials-in-r/154-stepwise-regression-essentials-in-r/
# Train the model 
step.model <- train(item_cnt_day ~., data = df,
                    method = "leapBackward", 
                    tuneGrid = data.frame(nvmax = 1:5),
                    trControl = train.control
                    )
step.model$results
step.model$bestTune
summary(step.model$finalModel)
coef(step.model$finalModel, 5)
# prepare model on training data
linear_model = lm(formula = item_cnt_day ~ shop_id + item_id,
                  data = df)
# Make predictions on the test dat
result = predict(linear_model, df_test[,c("shop_id","item_id")]) 
submission =  data.frame(ID = df_test$ID,item_cnt_month = result)
head(submission)
write.csv(submission, file = "data/kaggle_predict_futuresales_sub4.csv", row.names = F)

