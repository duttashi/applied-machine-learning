# data source: https://www.kaggle.com/ayushggarg/all-trumps-twitter-insults-20152021/tasks?taskId=3231

library(tidyverse)
library(tidytext)
library(tidyr)
data("stop_words")

# clean workspace
rm(list = ls())
# load data
df_tweets<- read.csv("data/kaggle_trump_insult_tweets_2014_to_2021.csv", stringsAsFactors = FALSE)
# EDA

## drop irrelevant cols
df_tweets$X<- NULL
## split date into separate cols

# data cleaning
df_tweets_tidy<-df_tweets %>%
  # unnest tokens in tweets
  unnest_tokens(word, tweet,token = "words", strip_punct = FALSE) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  # filter out word like https
  #mutate_all(gsub("https","NA",.))
  #filter(!str_detect(word, 'https')) %>%
  #!grepl("https") %>%
  # filter out the NAs
  filter(!is.na(word)) %>%
  filter(!is.na(target))%>%
  # remove stop words
  anti_join(stop_words) 

colSums(is.na(df_tweets_tidy))
# remove a specified string from the text
df_tweets_tidy<- df_tweets_tidy[!grepl("https", df_tweets_tidy$word),]

# use dplyr’s count() to find the most common words
df_tweets_tidy %>%
  count(word, sort = TRUE) %>%
  View()
#  create a visualization of the most common words 
df_tweets_tidy %>%
  count(word, sort = TRUE) %>%
  filter(n > 600) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col() +
  labs(y = NULL)

