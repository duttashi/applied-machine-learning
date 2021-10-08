# Created on Fri Oct  8 11:02:08 2021
# Objective: Given a dataframe, Get a list of categories for categorical variable
# @author: Ashish

# create some fake data
df <- data.frame(Name = c("Jon", "Bill", "Maria", "Ben", "Tina"),
                 Age = c(23, 41, 32, 58, 26),
                 sex = c('M','T','F','M','F'))
str(df)
# coerce column to categorical
df$sex<- as.factor(df$sex)
str(df)

# solution 1: using sapply()
sapply(df, levels)

# solution 2: using pipe operator
library(dplyr)
df %>%
  sapply(levels)

