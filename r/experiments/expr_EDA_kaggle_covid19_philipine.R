# Analysis objective: Exploratory data analysis
# Possible hypothesis to check are;
# 1. covid19 transmission is nationality dependent

# required libraries
library(tidyverse)

rm(list = ls())

# Exploratory Data Analysis
df<- read.csv("data/kaggle_covid19_philip.csv", 
              na = c("None", NA), stringsAsFactors = TRUE)
# lowercase all character vars
df<-df %>%
  # lowercase all character variables
  mutate(across(where(is.factor), tolower)) %>%
  mutate(across(where(is.character), as.factor))
str(df)
table(df$Nationality)
# merge level china & taiwan in Nationality col
levels(df$Nationality)<- c("American","British","Chinese","Taiwanese","Filipino")
table(df$Nationality)


# visualizations
str(df)
colSums(is.na(df))
df %>%
  # filter out missing values in Nationality 
  filter(!is.na(Nationality)) %>%
  ggplot(., aes(x=Nationality, y=Age))+
  geom_boxplot(outlier.color = "red")+
  #geom_bar()+
  theme_bw()

df %>%
  # filter out missing values in Nationality 
  filter(!is.na(Nationality)) %>%
  ggplot(., aes(x=Status, y=Age))+
  geom_boxplot(outlier.color = "red")+
  #geom_bar()+
  theme_bw()

df %>%
  # filter out missing values in Nationality 
  filter(!is.na(Nationality)) %>%
  ggplot(., aes(x=Transmission, y=Age))+
  geom_boxplot(outlier.color = "red")+
  #geom_bar()+
  theme_bw()
