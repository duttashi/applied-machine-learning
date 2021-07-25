# https://www.kaggle.com/code?sortBy=voteCount&language=R&tagIds=13204


# clean the workspace
rm(list = ls())
# load required libraries
library(tidyverse)

# load required dataset

df <- read.csv("data/kaggle_women_clothing_ecom_reviews.csv",
               na=c("",NA))

colnames(df)
df$X<- NULL

# Data cleaning

# lowercase all column names in the dataframe
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}
df <- lowercase_cols(df)
sum(is.na(df))
colSums(is.na(df))
table(df$class.name)

str(df)
df <- df %>%
  mutate(title = factor(title),
         review.text = factor(review.text),
         division.name = factor(division.name),
         department.name = factor(department.name),
         class.name = factor(class.name))
str(df)
df %>%
  group_by(department.name) %>%
  summarise(cnt = n()) %>%
  arrange(cnt)

df %>%
  group_by(class.name) %>%
  summarise(cnt = n()) %>%
  arrange(cnt)

df %>%
  group_by(division.name) %>%
  summarise(cnt = n()) %>%
  arrange(cnt)

highDiv <- df %>%
  group_by(division.name) %>%
  summarise(cnt = n()) %>%
  arrange(desc(cnt))

# Individual feature visualisations
df %>%
  group_by(department.name) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= department.name, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="department name", y="Frequency")+
  coord_flip()+
  theme_bw()

df %>%
  group_by(class.name) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= class.name, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="class name", y="Frequency")+
  coord_flip()+
  theme_bw()

df %>%
  group_by(division.name) %>%
  summarise(cnt = n()) %>%
  arrange(cnt) %>%
  ggplot(aes(reorder(x= division.name, -cnt, FUN=min), cnt))+
  geom_point(size=4)+
  labs(x="division name", y="Frequency")+
  coord_flip()+
  theme_bw()

# Suppose the target variable is division.name
# visualizing its distribution
df %>%
  ggplot(aes(x=division.name))+
  geom_bar()+
  theme_bw()

# Feature interaction visualizations
# reference: https://www.kaggle.com/headsortails/personalised-medicine-eda-with-tidy-r
str(df)
df %>%
  filter(!is.na(department.name) %in% str_c(highDiv$division.name)) %>%
  ggplot(aes(department.name))+
  geom_bar()+
  scale_y_log10() +
  theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=7)) +
  facet_wrap(~ division.name)+
  theme_bw()

df %>%
  filter( !is.na(department.name) %in% str_c(highDiv$division.name)) %>%
  ggplot(aes(division.name))+
  geom_bar()+
  scale_y_log10() +
  theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=7)) +
  facet_wrap(~ department.name)+
  theme_bw()


foo <- df %>%
  na.omit() %>%
  filter(division.name %in% str_c(highDiv$division.name)) %>%
  group_by(division.name, department.name) %>%
  summarise(ct = n())

y_labels <- str_sub(foo$department.name, start = 1, end = 5)

foo %>%
  na.omit() %>%
  ggplot(aes(reorder(division.name, ct, FUN = median), reorder(department.name, ct, FUN = median))) +
  geom_count() +
  labs(x = "division.name", y = "department.name") +
  theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=7),
        axis.ticks = element_blank(), axis.text.y = element_blank(),
        legend.position = "none")+
  theme_bw()

## Text data analysis
str_sub(df$review.text[1], start = 1, end = 1e3)

### Feature Engineering
# 1. Text length - txt_len
df <- df %>%
  na.omit() %>%
  mutate(txt_len = str_length(review.text))

## Overall distribution of text
str(df)
df %>%
  drop_na() %>%
  ggplot(aes(x = txt_len, fill = division.name))+
  geom_histogram(binwidth = 50)+
  labs(x = "Length of review text")+
  theme_bw()

# Now, let’s see whether this distribution changes for the different target Classes. First, a facet wrap comparison:
str(df)

foo <- df %>%
  select(clothing.id, txt_len)
bar <- df %>%
  select(clothing.id, department.name)

full_join(foo, bar, by = "clothing.id") %>%
  ggplot(aes(txt_len)) +
  geom_density(fill = "red") +
  labs(x = "Length of text entry") +
  facet_wrap(~ department.name)

foo <- df %>%
  select(clothing.id, txt_len)
bar <- df %>%
  select(clothing.id, class.name)

full_join(foo, bar, by = "clothing.id") %>%
  ggplot(aes(txt_len)) +
  geom_density(fill = "red") +
  labs(x = "Length of text entry") +
  facet_wrap(~ class.name)

foo <- df %>%
  select(clothing.id, txt_len)
bar <- df %>%
  select(clothing.id, department.name)

full_join(foo, bar, by = "clothing.id") %>%
  ggplot(aes(txt_len)) +
  stat_ecdf(geom = "step") +
  stat_ecdf(aes(txt_len, color = department.name), geom = "step") +
  labs(x = "Length of text entry")+
  theme_bw()

# And the median lengths for each class in department
full_join(foo, bar, by = "clothing.id") %>%
  group_by(department.name) %>%
  summarise(l_med = median(txt_len))

## Text mining
df <- df %>%
  mutate(txt_neg = str_count(review.text, c("bad")),
         txt_pos = str_count(review.text, c("love")))
#table(df$txt_neg)
str(df)
foo <- df %>%
  select(clothing.id, txt_pos, txt_neg)
bar <- df %>%
  select(clothing.id, division.name)

full_join(foo, bar, by = "clothing.id") %>%
  ggplot(aes(txt_neg)) +
  geom_bar() +
  scale_y_log10() +
  # scale_x_log10() +
  facet_wrap(~ division.name)+
  theme_bw()

# And here we plot the ratio of the mean occurence per class of the word “bad” over the mean occurence of the word “love”:
foo <- df %>%
  select(clothing.id, txt_pos, txt_neg)
bar <- df %>%
  select(clothing.id, division.name)

full_join(foo, bar, by = "clothing.id") %>%
  group_by(division.name) %>%
  summarise(mean_pos = mean(txt_pos),
            mean_neg = mean(txt_neg),
            path_pos = mean(txt_neg)/mean(txt_pos)) %>%
  ggplot(aes(reorder(division.name, -path_pos, FUN = max), path_pos)) +
  geom_point(colour = "red", size = 3) +
  labs(x = "division.name", y = "# occurences 'negative' / # occurences 'positive'")+
  theme_bw()

### Text analysis with tidytext
library(tidytext)
str(df)
t1 <- df %>%
  select(clothing.id, review.text) %>%
  mutate(text= as.character(review.text)) %>%
  unnest_tokens(word, text)
data("stop_words")

t1 <- t1 %>%
  anti_join(stop_words, by = "word") %>%
  filter(str_detect(word, "[a-z]"))

# Lets take a a look at the overall most popular words and their frequencies

# t1 %>%
#   count() %>%
#   filter(n>10) %>%
#   mutate(word = reorder(word, n)) %>%
#   ggplot(aes(word, n)) +
#   geom_col() +
#   xlab(NULL) +
#   coord_flip()+
#   theme_bw()


