rm(list = ls())

# data source: https://www.kaggle.com/nehaprabhavalkar/indian-food-101

library(tidyverse)

# read data
df <- read_csv(file = "data/kaggle_indian_food.csv",
               na = c(-1,"NA"))
glimpse(df)

# create 10 cols
cols2Add<- paste("ingre",1:10, sep = "_")
df[, cols2Add]<- NA

# separate ingredients into separate cols
df<- df %>%
  separate(ingredients, into = c("ingre_1","ingre_2","ingre_3",
                                 "ingre_4","ingre_5","ingre_6",
                                 "ingre_7","ingre_8","ingre_9",
                                 "ingre_10"), 
           sep = ",", extra = "drop", fill = "right")
colSums(is.na(df))
# drop cols
names(df)
df<- df[,-c(7:11)]
colSums(is.na(df))
glimpse(df)
