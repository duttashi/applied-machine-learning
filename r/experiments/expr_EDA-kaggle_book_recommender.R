# Data analysis Book recommendation 
# Objective: to predict whether a customer will buy insurance from airline or not 
# Script author: Ashish Dutt
# Script create date: 18/1/2020
# Script last modified date: 
# Email: ashishdutt@yahoo.com.my

# clean the workspace
rm(list = ls())

# required libraries
library(tidyverse)

# load data
df_books<- read.csv("data/kaggle_booksdata_books.csv",
                    stringsAsFactors = F, na.strings = c("",NA))
df_users<- read.csv("data/kaggle_booksdata_users.csv",
                    stringsAsFactors = F, na.strings = c("",NA))
df_ratings<- read.csv("data/kaggle_booksdata_ratings.csv",
                    stringsAsFactors = F, na.strings = c("",NA))
sum(is.na(df_books)) # 6 missing values
colSums(is.na(df_books))
sum(is.na(df_users)) # 110762 missing values
colSums(is.na(df_users))
sum(is.na(df_ratings)) # zero missing values

# EDA

# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}

df_books<- lowercase_cols(df_books)
df_users<- lowercase_cols(df_users)
df_ratings<- lowercase_cols(df_ratings)

# drop cols
df_books$image.url.s<- NULL
df_books$image.url.l<- NULL
df_books$image.url.m<- NULL

# rename column names
df_books<- df_books %>%
  rename(c(bookTitle = book.title, bookAuth = book.author,
           year_publ = year.of.publication))
df_users<- df_users %>%
  rename(userID = user.id)
df_ratings <- df_ratings %>%
  rename(c(userID = user.id, bookRating = book.rating))

colnames(df_books)
colnames(df_users)
# split location into separate cols
df_users <- df_users %>%
  separate(location, into = c("city","state","country"), sep = ",")
# keep books published since 1900
df_books <- df_books %>%
  filter(year_publ>=1900 & year_publ<=2021)
colnames(df_books)

# Get data of only those users who have given ratings: inner join users with ratings
df_userating <- df_users %>%
  inner_join(df_ratings) %>%
  # filter out toddlers and ppl above 91 years age
  filter(age>5 & age<91) 
colnames(df_userating)

# join users, ratings and books on book isbn
df_userating_books <- df_books %>%
  inner_join(df_userating, by="isbn")

# write data to disc
write.csv(df_userating_books, file = "data/kaggle_booksdata_clean.csv")
