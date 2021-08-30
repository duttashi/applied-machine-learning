

# read in the libraries we're going to use
library(tidyverse) # general utility & workflow functions
library(tidytext) # tidy implimentation of NLP methods
library(topicmodels) # for LDA topic modelling 
library(tm) # general text mining functions, making document term matrixes
library(SnowballC) # for stemming

tweet_train<- read.csv("data/kaggle_corona_nlp_train.csv",
                       na.strings = c("",NA))

tweet_test<- read.csv("data/kaggle_corona_nlp_test.csv",
                      na.strings = c("",NA))

# Merge 2 datasets
tweets <- bind_rows(tweet_train, tweet_test)
colnames(tweets)
str(tweets)
ggplot(tweets, aes(x = Sentiment, fill = Sentiment)) + 
  geom_bar() +
  theme_classic() +
  theme(axis.title = element_text(face = 'bold', size = 15),
        axis.text = element_text(size = 13)) +
  theme(legend.position = 'none')

# check for missing value
summary(is.na(tweets))
colSums(is.na(tweets))

# tweet count by each sentiment
tweets %>%
  group_by(Sentiment) %>%
  count() %>%
  arrange(desc(n))

tweets %>%
  group_by(Sentiment) %>%
  count(sort = TRUE) %>%
  rename(freq = n) %>%
  ggplot(aes(x = reorder(Sentiment, -freq), y = freq)) + 
  geom_bar(stat = 'identity', fill = 'skyblue') +
  theme_classic() +
  xlab('Tweet Category') +
  ylab('frequency') +
  geom_text(aes(label = freq), vjust = 1.2, fontface = 'bold') +
  theme(axis.title = element_text(face = 'bold', size = 15),
        axis.text = element_text(size = 13, angle = 90))
## Wrk to do
## 1. split tweetAt into date time cols
head(tweets$Location)
