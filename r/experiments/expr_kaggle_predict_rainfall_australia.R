# Exploratory Data analysis for rainfall prediction
# Objective: To determine variables relevant to rainfall prediction
# data source: https://www.kaggle.com/jsphyg/weather-dataset-rattle-package
# Script author: Ashish Dutt
# Script create date: 29/3/2021
# Script last modified date: 29/3/2021
# Email: ashish.dutt8@gmail.com
# clean the worspace
rm(list = ls())
# load required libraries
library(tidyr) # for separate
library(magrittr) # for %>%
library(dplyr) # for filter()

# load required data
df<- read.csv(file = "data/kaggle_WeatherAUS.csv",
              header = TRUE, sep = ",")
# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}

df<- lowercase_cols(df)

# separate the date
df <- df %>%
  separate(date, into = c("year","month","date"),
           sep = "-")
head(df)
table(df$year, df$month)
# year 2007, data present only for nov & dec months
# year 2017, data present only for jan-june months
# filter data with complete months
names(df)
str(df)
df$date<- as.Date(df$date)
df$mon_yr = format(df$date, "%Y-%m") 
df <- df %>%
  group_by(mon_yr) %>%
  filter(date == max(date))


df %>%
  #select(Date, Price) %>%
  group_by(year,month) %>%
  summarise(mean(rainfall, na.rm = TRUE))
  # summarise(mean(rainfall, na.rm = TRUE)) 
