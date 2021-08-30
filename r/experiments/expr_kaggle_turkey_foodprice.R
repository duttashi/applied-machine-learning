

# Data Source: https://www.kaggle.com/leventoz/food-prices-in-turkey
# Response/dependent variable: price
# Problem type: regression
# Questions to solve:
## Q. Identify variables for high food price

# clean the workspace
rm(list = ls())
# load required libraries
library(tidyverse)

# load required dataset
df_train<- read.csv("data/kaggle_turkey_foodprice_train.csv")
df_test<- read.csv("data/kaggle_turkey_foodprice_test.csv")
sum(is.na(df_train)) # 0 missing value
sum(is.na(df_test))

# Data cleaning
# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}
df_train <- lowercase_cols(df_train)
df_test <- lowercase_cols(df_test)


# Filter out data where place = national average
vals2rmv <- c("Electricity","Fuel (gas)",
              "Fuel (petrol-gasoline)", "Transport (public)")
x<- df_train %>%
  #filter(place!="National Average") %>%
  #mutate(productname = sub(" - Retail"," ",productname)) %>%
  filter(productname %in% "Electricity")

vals2rmv <- c('Electricity','Fuel (gas)','Fuel (petrol-gasoline)')
x <- subset(df_train, !productname %in% vals2rmv)


# Rename factor levels in productName
table(df_train$productname)

df<- data.frame(col1 = c("a","b","c","d"),
                col2 = c("p","q","r","s"))
df
vals2rmv<- c("a","d")
df<- df %>%
  #filter(col1 != "b")
  #mutate(col1 = sub(vals2rmv,"NA",col1))
  subset(!col1 %in% vals2rmv)

df

# df <- merge(df_train, df_test, by="ProductName")


# Data cleaning
# Missing value treatment
# impute missing values with median or mode

df_clean<- data.frame(lapply(df,function(x) 
{
  if(is.numeric(x)) 
    ifelse(is.na(x),median(x,na.rm=T),x) 
  else x
}))
sum(is.na(df_clean))

# rename the variables
colnames(df_clean)
df_clean<- df_clean %>%
  rename("sex"="FEMALE") %>%
  recode("0"="")
