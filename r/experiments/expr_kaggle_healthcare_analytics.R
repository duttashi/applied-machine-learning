
# DAta Source: https://www.kaggle.com/shivan118/healthcare-analytics 
# Task: Predict the probability of a favorable outcome. Where outcome is defined
# as getting a health_score

# required libraries
library(tidyverse)
# EDA

# read the data
df_train <- read_csv("data/kaggle_healthcare_train.csv", na=c("",NA))
df_test <- read_csv("data/kaggle_healthcare_test.csv", na=c("",NA))
sum(is.na(df_train))
colSums(is.na(df_train)) # 334
colSums(is.na(df_test)) # 0 
str(df_train)
str(df_test)

# Data Engineering
# split the Registration date into 3 columns, day, month, year
df_train <- df_train %>%
  separate(Registration_Date, into = c("reg_day","reg_month","reg_year"),
           sep = "-")
df_test <- df_test %>%
  separate(Registration_Date, into = c("reg_day","reg_month","reg_year"),
           sep = "-")

ggplot(data = df_train)+
  geom_bar(aes(x=reg_year))
ggplot(data = df_test)+
  geom_bar(aes(x=reg_year))
str(df_train)
