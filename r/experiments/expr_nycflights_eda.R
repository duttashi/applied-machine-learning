rm(list = ls())
library(tidyverse)
library(nycflights13)

df<- flights
dim(df)
colnames(df)
str(df)
range(df$time_hour) # data for 1 year 2013 only

# 1. count df with arrival & departure delay more than 5 hours
# Solution: both cols got missing data. Filter out the missing vals,
# select rows where condition meets >5; and then count such rows
range(df$dep_delay)
colSums(is.na(df))

# create new cols
df<- df %>%
  #mutate(flight_date= mdy)
  separate(col = time_hour, into = c("flight_date","flight_time"),
           sep = " ")
View(df)  

# 2. count flight departure by time
# solution
colnames(df)

df %>%
  filter(!is.na(arr_delay) & !is.na(dep_delay)) %>%
  group_by(origin,dest) %>%
  summarise(cnt = n()) %>%
  filter(cnt > 2000) %>%
  ggplot(aes(reorder(x=dest, -cnt, FUN=min), cnt))+ geom_point()+
  labs(x="flight destination", y="Frequency")+
  coord_flip()+
  theme_bw()

