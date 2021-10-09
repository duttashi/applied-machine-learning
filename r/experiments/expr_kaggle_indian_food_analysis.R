rm(list = ls())

# data source: https://www.kaggle.com/nehaprabhavalkar/indian-food-101

library(tidyverse)

# read data
df <- read_csv(file = "data/kaggle_indian_food.csv",
               na = c(-1,"NA"))
colSums(is.na(df))
glimpse(df)

?geom_histogram
# basic visuals
ggplot(data = df)+
  geom_bar(aes(x= diet), stat = "count")+
  theme_bw()
