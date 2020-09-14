library(readr)

# data source: https://www.kaggle.com/aungpyaeap/fish-market 
# task: estimate fish weight
# Weight is the dependent variable


# clean the workspace
rm(list = ls())

# load required libraries
library(dplyr)
library(plyr)
library(magrittr)
library(ggplot2)
library(caret)

fish<- read.csv("data/Fish.csv")
str(fish)

# EDA
# rename variable names

fish<- rename(fish, c("ï..Species"="species",
                      "Length1"="LengthV",
                      "Length2"="LengthD",
                      "Length3"="LengthCL"))
fish$species<- factor(fish$species)
summary(fish)
cat("Are there any missing value in the dataset?" ,any(is.na(fish)))

fish<-fish %>%
  filter(Weight>0)

ggplot(fish,aes(x=Weight,fill=species))+
  geom_histogram(alpha=0.5,col="black",bins=30)

# predictive modelling
# 4. Find collinear features (works only for numeric features) as identified by a correlation coefficient greater than a specified value
str(fish)
fish_corr = cor(fish[,c(2:7)])
hc = findCorrelation(fish_corr, cutoff=0.75) # find vars that are 75% correlated 
hc = sort(hc)
colnames(fish[,hc])
temp = fish[,-c(hc)]
temp$species <- fish$species
fish_clean<- temp

# multiple linear regression model
str(fish_clean)
fish.reg <- lm(Weight ~ Height, data = fish_clean)
summary(fish.reg)