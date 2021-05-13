
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
df_full<- bind_rows(df_lst) 

# Data cleaning
str(df_full)

# split col created_date into date and time
head(df_full)
df_full$create_date<- as.Date(df_full$created_date)
df_full$create_time<- format(df_full$created_date,"%H:%M:%S")
head(df_full$create_date)
head(df_full$create_time)

# drop cols not required for further analysis
df_full$X1<- NULL
df_full$created_date<- NULL
df_full$created_timestamp<- NULL
str(df_full)


# 4. write combined partially clean data to disk
write_csv(df_full, file = "data/kaggle_reddit_data/reddit_data_full.csv")
