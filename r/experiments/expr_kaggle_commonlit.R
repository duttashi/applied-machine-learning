# Data source: https://www.kaggle.com/c/commonlitreadabilityprize/overview
# Problem statement: To identify the appropriate reading level of a passage of text.
# For each row in the test set, you must predict the value of the target.
# Problem type: Regression
# Evaluation metric: RMSE


# load required libraries
library(readr) # for read_csv()
library(caret) # for nearZeroVar()
library(tidytext)
library(dplyr)
library(magrittr) # for %>% operator
library(ggplot2)
library(tidyr) # for pivot_wider()

# clean the workspace
rm(list = ls())

# read the data
df_train<- read_csv("data/kaggle_commonlit_train.csv", na = c("","NA"))
df_test<- read_csv("data/kaggle_commonlit_test.csv", na = c("","NA"))

sum(is.na(df_train)) # 4008
colSums(is.na(df_train)) # url_legal, license

# DATA PREPROCESSING & INITIAL VISUALIZATION
colnames(df_train)

# Step 1: To create a tidy dataset, we need to restructure it in the one-token-per-row format, which is done with the unnest_tokens() function.
df_train_tidy<- df_train %>%
  select(id, excerpt, target, standard_error) %>%
  unnest_tokens(word, excerpt)

# Step 2: To remove stop words such as “the”, “of”, “to”, and so forth.
# We can remove stop words (kept in the tidytext dataset stop_words) with an anti_join()
data("stop_words")
df_train_tidy <- df_train_tidy %>%
  anti_join(stop_words, c(word = "word"))
# use dplyr’s count() to find the most common words
df_train_tidy %>%
  count(word, sort = TRUE)

# To to create a visualization of the most common words  
df_train_tidy %>%
  count(word, sort = TRUE) %>%
  filter(n > 300) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col() +
  labs(y = NULL)

# feature engineering: add new cols
colnames(df_train_tidy)
df_train_tidy<- df_train_tidy %>%
  count(word, sort = TRUE) %>%
  mutate(proportion = n / sum(n))

# sentiment analysis of tidy data 
# install.packages("textdata", dependencies = TRUE)
# reference: https://www.tidytextmining.com/sentiment.html
get_sentiments("afinn")
get_sentiments("bing")
get_sentiments("nrc")

# With data in a tidy format, sentiment analysis can be done as an inner join. 

# Q. What are the most common joy words in text? Let’s use count() from dplyr.
nrc_joy<- get_sentiments("nrc") %>% 
  filter(sentiment == "joy")
colnames(nrc_joy)

df_train_tidy %>%
  inner_join(nrc_joy) %>%
  count(word, sort = TRUE)
