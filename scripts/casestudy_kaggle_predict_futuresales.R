# Objective: starter code for predicting future sales
# evaluation metric- RMSE
# data source: https://www.kaggle.com/c/competitive-data-science-predict-future-sales

# reference script: https://www.kaggle.com/jeetranjeet619/predict-future-sales-r

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
# coerce to categorical
df$month<- as.factor(df$month)
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

# read the clean data
df<- read.csv(file = "data/kaggle_predict_futuresales_clean.csv",
              header = TRUE, sep = ",")