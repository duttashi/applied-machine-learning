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

df_clean <- df %>%
  # filter number of comments less than 0. this will take care of 0 & -1 comments
  filter(num_comments > 0 ) %>%
  # filter posts with NA
  filter(!is.na(post)) %>%
  # filter subreddit_subscribers with NA
  filter(!is.na(subreddit_subscribers)) %>%
  # filter crossposts with NA
  filter(!is.na(num_crossposts)) %>%
  # filter create date, create time with NA
  filter(!is.na(create_date)) %>%
  filter(!is.na(create_time)) %>%
  # filter character cols with only text data. remove all special characters data
  filter(str_detect(str_to_lower(author), "[a-zA-Z]")) %>%
  filter(str_detect(str_to_lower(title), "[a-zA-Z]")) %>%
  filter(str_detect(str_to_lower(id),"[a-zA-Z0-9]")) %>%
  filter(str_detect(str_to_lower(post),"[a-zA-Z]")) %>%
  # separate date into 3 columns
  separate(create_date, into = c("create_year","create_month","create_day")) %>%
  # separate time into 3 columns
  separate(create_time, into = c("create_hour","create_min","create_sec")) %>%
  # coerce all character cols into factor
  mutate_if(is.character,as.factor)

##
df_clean<-df_clean %>%
  filter(str_detect(str_to_lower(post), url_pattern)) 


dim(df_clean) # [1] 4219   15
summary(df_clean)
# 4. write combined partially clean data to disk
write_csv(df_clean, file = "data/kaggle_reddit_data/reddit_data_clean.csv")

# read clean file
library(stringr)

df<- read_csv(file = "data/kaggle_reddit_data/reddit_data_clean.csv")
colnames(df)
view(df$author)
colSums(is.na(df))

# total comments per user
df %>%
  group_by(author, create_year, create_month) %>%
  summarise(num_comment = sum(num_comments))



# Tidy Text 
# reference: 
# https://www.tidytextmining.com/tidytext.html
# https://juliasilge.com/blog/life-changing-magic/

library(tidytext)
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






