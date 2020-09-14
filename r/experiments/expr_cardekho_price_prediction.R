# data source: https://www.kaggle.com/nehalbirla/vehicle-dataset-from-cardekho


# required libraries
library(tidyverse)
library(data.table) # for setnames()
library(magrittr)
# clean the workspace
rm(list = ls())
# read data in memory
df<- read.csv("data/car_data_1.csv",header=T, 
              na.strings=c("","NA"), stringsAsFactors = FALSE)
# EDA
colnames(df)
head(df)
str(df)

df$name<- as.factor(df$name)
df$fuel<- as.factor(df$fuel)
df$seller_type<- as.factor(df$seller_type)
df$transmission<- as.factor(df$transmission)
df$owner<- as.factor(df$owner)

ggplot(data = df, aes(x= transmission, y= selling_price))+
  geom_boxplot(aes(colour=fuel))+
  theme_bw()
ggplot(data = df, aes(x= transmission, y= selling_price))+
  geom_boxplot(aes(colour=owner))+
  theme_bw()

luxury_cars<- df[df$selling_price>5000000,]
budget_cars <- df[df$selling_price<5000000,]
ggplot(data = budget_cars, aes(x= transmission, y= selling_price))+
  geom_boxplot(aes(colour=fuel))+
  theme_bw()
str(budget_cars)
table(budget_cars$seller_type)

# collapse factor levels

table(df$year)

df %<>%
  mutate(decade=case_when(
    year %in% 1992:1999 ~ "1990s",
    year %in% 2000:2009 ~ "2000s",
    year %in% 2010:2019 ~ "2010s",
    year %in% 2020 ~ "2020s"
  ))
head(df)
df$decade<- as.factor(df$decade)
table(budget_cars$decade)
ggplot(data = df, aes(x= transmission, y= selling_price))+
  geom_boxplot(aes(colour=decade))+
  theme_bw()
