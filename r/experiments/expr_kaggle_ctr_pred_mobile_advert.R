# Data Source: https://www.kaggle.com/c/avazu-ctr-prediction/data
# Question: Predict whether a mobile ad will be clicked
# target variable: click: 0/1 for non-click/click
# other variables descrption is as follows;
# 
library(tidyverse)
library(data.table)
library(lubridate)
library(hms)
dat<- fread(input = "data/kaggle_ctr_train_data.csv")

# Random sample the original dataframe to reduce size on disk
df<- dat[sample(nrow(dat),500000),]
write.csv(df, file = "data/kaggle_ctr_train_sampled_data.csv") # 88MB on disk

# delete the original data from the local file system as its size is >5GB
# delete the original dataframe r object too
rm(dat)

# EDA
head(df)
sum(is.na(df))

# rename target variable values
df$clicks <- recode_factor(df$click,"0"="no_click","1"="click")
# drop the original click column
df$click<-NULL

# split the hour variable into yy-mm-dd-hour format
df$date_time <- lubridate::ymd_h(df$hour)
head(df$date_time)
str(df$date_time)

# separate the date_time column into date and time cols
df<- separate(data = df, col = date_time, into  = c('ctr_date', 'ctr_time'), sep = ' ')
# separate the date and time column into year,month, day and hour cols
df<- separate(data = df, col = ctr_date, into  = c('ctr_year', 'ctr_month','ctr_day'), sep = '-')
df<- separate(data = df, col = ctr_time, into  = c('ctr_hour', 'ctr_min','ctr_sec'), sep = ':')
head(df)
df$hour<-NULL

# write clean file to disk
write.csv(df, file = "data/kaggle_ctr_train_sampled_clean.csv") # 103 MB on disk
# clean the workspace
rm(list = ls())
# read the clean data in memory for further analysis
df_cln<- read.csv("data/kaggle_ctr_train_sampled_clean.csv")
table(df_cln$clicks) # imbalanced data
head(df_cln)

table(df_cln$ctr_year) # drop var for zero variance
table(df_cln$ctr_month) # drop var for zero variance
table(df_cln$ctr_sec) # drop var for zero variance
table(df_cln$ctr_min) # drop var for zero variance

table(df_cln$ctr_hour) # keep var
table(df_cln$ctr_day) # keep var

# drop the followig vars with zero variance
colnames(df_cln)
df_cln<- df_cln[,-c(1,25:26,29:30)]
# write clean file to disk
write.csv(df_cln, file = "data/kaggle_ctr_train_sampled_clean.csv") # 103 MB on disk

# Initial plots to understand spread of data
str(df_cln)
# day and hour got no outliers
ggplot(data = df_cln, mapping = aes(x=clicks, y=ctr_day))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()
ggplot(data = df_cln, mapping = aes(x=clicks, y=ctr_hour))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()
ggplot(data = df_cln, mapping = aes(x=clicks, y=C20))+
  geom_boxplot(outlier.colour = "red")+
  theme_light()
# c14-17, c19, c21 outliers present. c18,c20 got no outliers 