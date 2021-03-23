# competition: predict number of upvotes
# hosted by: analytics vidya
# url: https://datahack.analyticsvidhya.com/contest/enigma-codefest-machine-learning-1/#ProblemStatement
# Problem type: regression
# evaluation metric: RMSE

# require libraries
library(tidyverse)

# read the data
dat_train<- read_csv("data/av_train_NIR5Yl1.csv", na = c("","NA"))
dat_test<- read_csv("data/av_test_8i3B3FC.csv", na = c("","NA"))
colnames(dat_train)
colnames(dat_test)
table(dat_train$Upvotes)
