# clean the worspace
rm(list = ls())

# load required libraries
library(tidyverse)
# load data
df_raw <- read_csv('data/kaggle_5000_movies.csv', na=c("",NA))
str(df_raw)
sum(is.na(df_raw)) # 2698 missing values
colSums(is.na(df_raw))
