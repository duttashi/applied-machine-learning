# read kaggle reddit comments clean file
# required file: data/kaggle_reddit_data/reddit_data_clean.csv

# clean the workspace
rm(list = ls())
# load required libraries
library(stringr)
library(tidyverse)
library(tidytext)

df<- read_csv(file = "data/kaggle_reddit_data/reddit_data_clean.csv")
str(df)
colnames(df)

# total comments per user
df %>%
  group_by(author, create_year, create_month) %>%
  summarise(num_comment = sum(num_comments))

# Tidy Text 
# reference: 
# https://www.tidytextmining.com/tidytext.html
# https://juliasilge.com/blog/life-changing-magic/

data("stop_words")
df1<- df %>%
  mutate(linenumber = row_number(),
         # post_text = str_extract(post, "[a-z]+")
         # post_text = str_extract(post, "[a-z']+")
         post_text = str_replace_all(post, "[^a-zA-Z]", "")
  ) %>%
  ungroup() %>%
  unnest_tokens(word,post) %>%
  anti_join(stop_words)

df1 %>%
  count(word, sort = TRUE)

# visualize the most common words
df1 %>%
  count(word, sort = TRUE) %>%
  filter(n > 600) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word)) +
  geom_col() +
  labs(y = NULL)

# word_frequency <- df1 %>%
#   mutate(word = str_extract(word, "[a-z']+")) %>%
#   count(author, word, sort = TRUE) %>%
#   group_by(author) %>%
#   mutate(proportion = n / sum(n))  
#   # select(-n) %>% 
#   # pivot_wider(names_from = author, values_from = proportion) %>%
#   # pivot_longer(cols = author, names_to = "author", values_to = "proportion")

# sentiment analysis
df2_afinn<-df1 %>%
  group_by(author) %>%
  mutate(linenumber = row_number(),
         post_text = str_replace_all(post_text, "[^a-zA-Z]", "")) %>%
  #inner_join(get_sentiments("bing"))
  inner_join(get_sentiments("afinn")) %>%
  #group_by(index = linenumber) %>% 
  summarise(sentiment = sum(value)) %>% 
  mutate(method = "AFINN")

df2_bing <- df1 %>%
  group_by(author) %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

df2_bing %>%
  group_by(sentiment) %>%
  slice_max(n, n = 10) %>% 
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(n, word, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(x = "Contribution to sentiment",
       y = NULL)+
  theme_bw()

# df_sentiment_by_author<-df1 %>%
#   inner_join(get_sentiments("bing")) %>%
#   group_by(author) %>% 
#   summarise(post_count = n(), sentiment)
#   #count(post_count)%>%
#   #count(author, index = linenumber %/% 80, sentiment) %>%
#   #pivot_wider(names_from = sentiment, values_from = post_count, values_fill = 0) %>% 
#   #pivot_wider(names_from = author, values_from = post_count, values_fill = 0) %>% 
#   #mutate(sentiment = positive - negative)

# df_sentiment_by_post<-df1 %>%
#   inner_join(get_sentiments("bing")) %>%
#   count(author, post_count = linenumber %/% 80, sentiment) %>%
#   #count(post_count = n()) %>%
#   pivot_wider(names_from = sentiment, values_from = post_count, values_fill = 0) %>% 
#   mutate(sentiment = positive - negative)