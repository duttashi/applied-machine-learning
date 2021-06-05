
# Data Source: https://www.kaggle.com/aungpyaeap/supermarket-sales

library(tidyverse)

# load data
df <- read.csv("data/kaggle_supermarket_sales.csv",na=c("","NA"))

# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}

df<- lowercase_cols(df)
colnames(df)
head(df)  

# split date data into year, month, day cols
df<- separate(df, date, c('sale_month', 'sale_day', 'sale_year'), sep = "/",remove = TRUE)
# split time data into hour, minute cols
df<- separate(df, time, c('sale_hour', 'sale_min'), sep = ":",remove = TRUE)
head(df)

# create a new dataframe based on sale ordered by month & year
table(df$sale_month, df$sale_day)
sales_by_month<-df %>%
  group_by(payment,sale_month, sale_day ) %>%
  summarise_at(vars(quantity),sum)

sales_by_city<- df %>%
  group_by(city, product.line, gender) %>%
  summarise_at(vars(quantity), sum)
