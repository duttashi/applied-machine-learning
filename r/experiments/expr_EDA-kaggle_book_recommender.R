# Data analysis Book recommendation 
# Objective: to predict whether a customer will buy 
# Data source: https://www.kaggle.com/arashnic/book-recommendation-dataset
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

# split location into separate cols
df_users <- df_users %>%
  separate(location, into = c("city","state","country"), sep = ",")




# keep books published since 1900
df_books <- df_books %>%
  filter(year_publ>=1900 & year_publ<=2021)

# Get data of only those users who have given ratings: inner join users with ratings
df_userating <- df_users %>%
  inner_join(df_ratings) %>%
  # filter out toddlers and ppl above 91 years age
  filter(age>5 & age<91) 
# join users, ratings and books on book isbn
df_userating_books <- df_books %>%
  inner_join(df_userating, by="isbn")
# create a copy
df<- df_userating_books

# further data cleaning
df %>%
  count(country, sort = TRUE) %>%
  filter(n > 1000) %>%
  mutate(country = reorder(country, n)) %>%
  ggplot(aes(n, country)) +
  geom_col() +
  labs(y = NULL)
# filter countries with max user ratings as per the plot above
some_cntry<- c("usa","canada","united kingdom","germany","australia","spain","france","portugal","malaysia")
df<- df %>%
  filter(str_detect(country, some_cntry)) %>%
  # filter out books with zero rating
  filter(bookRating>0)
df$image.url.m<-NULL
table(df$bookRating)
# filter user ratings by country and user age
# plot
df %>%
  # plot children book readership by country
  #filter(age>6 & age <12) %>%
  # plot teen book readership by country
  #filter(age>11 & age <17) %>%
  # plot adult book readership by country
  filter((age>16 & age<100)) %>%
  count(country, sort = TRUE) %>%
  mutate(country = reorder(country, n)) %>%
  ggplot(aes(n, country)) +
  geom_col() +
  labs(y = NULL)

# FEATURE ENGINEERING
# create a new column called age_bracket. 
# group age: kids(6-11), teen(12-17), adult(18 and above)
df<- df %>%
  mutate(agegroup = case_when(age>5 & age<12 ~"kid",
                              age>11 & age<18 ~"teen",
                              age>17 & age<101 ~"adult"))
table(df$agegroup, df$bookRating)
str(df)
table(df$year_publ)
# group books published year
df<- df %>%
  mutate(yrpubgrp = case_when(year_publ<1981 ~"historic",
                              year_publ>1980 & year_publ<2001 ~"mediveal",
                              year_publ>2000 ~"modern"))
table(df$yrpubgrp, df$agegroup) # majority of book ratings are between year 1980-2000 and rated by adults

