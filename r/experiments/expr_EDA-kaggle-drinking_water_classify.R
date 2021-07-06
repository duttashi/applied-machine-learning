# https://www.kaggle.com/adityakadiwal/water-potability/tasks

# required libraries
library(tidyverse)

# Exploratory Data Analysis
df<- read.csv("data/kaggle_water_potability.csv")
sum(is.na(df))
colSums(is.na(df))
view(df)
table(df$Potability) # 0 means potable; 1 means not potable
str(df)

# DATA MANAGEMENT
# lowercase all vars
str(df)
df<-df %>%
  # lowercase all character variables
  rename_all(tolower)
colnames(df)
# recode target column variable values
df<-df %>%
  mutate(potability = recode(potability, 
                             "0"="potable", "1"="not_potable")
                             )
str(df)
# Initial plots
ggplot(data = df, aes( x=potability, y=hardness))+
  geom_boxplot(outlier.color = "red")+
  theme_light()

library(reshape2)
# multiple boxplots with all variables in a single graph

df1<-df %>%
  na.exclude() 
ggplot(melt(df), aes(variable, value)) +
  geom_boxplot()
         
# Missing data treatment
