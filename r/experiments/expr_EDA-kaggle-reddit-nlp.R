# data soruce: https://www.kaggle.com/maksymshkliarevskyi/reddit-data-science-posts

# clean the workspace
rm(list = ls())

# load required libraries
library(tidyverse)

# 1. reading multiple data files from a folder into separate dataframes
filesPath = "data/kaggle_reddit_data"
temp = list.files(path = filesPath, pattern = "*.csv", full.names = TRUE)
for (i in 1:length(temp)){
  nam <- paste("df",i, sep = "_")
  assign(nam, read_csv(temp[i], na=c("","NA")))
  }

#2. Read multiple dataframe created at step 1 into a list
df_lst<- lapply(ls(pattern="df_[0-9]+"), function(x) get(x))

#3. combining a list of dataframes into a single data frame
df<- bind_rows(df_lst) 
dim(df) # [1] 474033     16

# Data cleaning
str(df)
range(df$num_comments) # [1]   -1 2927
summary(df)

# split col created_date into date and time
df$create_date<- as.Date(df$created_date)
df$create_time<- format(df$created_date,"%H:%M:%S")

# lowercase all character data
df$title<- tolower(df$title)
df$author<- tolower(df$author)
df$post<- tolower(df$post)

# drop cols not required for further analysis
colnames(df)
df$X1<- NULL
df$created_date<- NULL
df$created_timestamp<- NULL
df$author_created_utc<- NULL
df$full_link<- NULL

# regex for text cleaning
replace_reg <- "https?://[^\\s]+|&amp;|&lt;|&gt;|\bRT\\b"

df_clean <- df %>%
  # filter number of comments less than 0. this will take care of 0 & -1 comments
  filter(num_comments > 0 ) %>%
  # filter posts with NA
  filter(!is.na(post)) %>%
  # filter subreddit_subscribers with NA
  filter(!is.na(subreddit_subscribers)) %>%
  filter(!is.na(num_crossposts)) %>%
  filter(!is.na(create_date)) %>%
  filter(!is.na(create_time)) %>%
  # separate date into 3 columns
  separate(create_date, into = c("create_year","create_month","create_day")) %>%
  # separate time into 3 columns
  separate(create_time, into = c("create_hour","create_min","create_sec")) %>%
  mutate(post = str_replace_all(post, replace_reg, "")) %>%
  mutate(title = str_replace_all(title, replace_reg, "")) %>%
  # coerce all character cols into factor
  mutate_if(is.character,as.factor)
  #unnest_tokens(word, text, token = "sentences")
colSums(is.na(df_clean)) # no missing

dim(df_clean) # [1] 4219   15
summary(df_clean)
# 4. write combined partially clean data to disk
write_csv(df_clean, file = "data/kaggle_reddit_data/reddit_data_clean.csv")

