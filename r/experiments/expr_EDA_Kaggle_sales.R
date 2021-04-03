# clean the workspace
rm(list = ls())

# Data source: https://www.kaggle.com/mysarahmadbhat/sales-data/tasks?taskId=3933
# my kaggle notebook: https://www.kaggle.com/ashishdutt/analysis-of-sales-data 
# required libraries
library(magrittr) # for pipe %>%
library(tidyr) # separate()
library(dplyr)
library(ggplot2)
# session info
sessionInfo()

# load required data
df<- read.csv(file = "data/kaggle_sales_data.csv",
              header = TRUE, sep = ",")
# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}

df<- lowercase_cols(df)

# clean date format
df$order_date<- gsub("-","/", df$order_date)
df$ship_date<- gsub("-","/", df$ship_date)
View(df)
# EDA
# split date data into year, month, date cols

df<- df %>%
  separate(order_date, into = c("order_month","order_day","order_year"),
           sep = "/")
df<- df %>%
  separate(ship_date, into = c("ship_month","ship_day","ship_year"),
           sep = "/")

# # filter sales on year
# df %>%
#   select(order_year, order_month, ship_year, ship_month, units_sold ) %>%
#   group_by(order_year, ship_year)
# # Aggregate all units sold by year
# df %>%
#   group_by(order_year) %>%
#   summarise(avg_units_sold = mean(units_sold))

# Task 1: Create a new data frame with 3 columns to have these values Month, Year, Number of Orders
orders_by_month_year<-df %>%
  group_by(order_month, order_year ) %>%
  summarise_at(vars(units_sold),sum)


# Task 2: Number of orders for each country and region combination
colnames(df)

orders_by_country_region<-df %>%
  group_by(country, region) %>%
  summarise_at(vars(units_sold), sum)

ggplot(data = orders_by_country_region,aes(x = units_sold)) + 
  geom_histogram(binwidth = 10000)+
  theme_bw()
