# data source url: https://archive.ics.uci.edu/ml/datasets/Dresses_Attribute_Sales
# objective: Exploratory Data Analysis

# clean the workspace
rm(list = ls())

# load required libraries
library(tidyverse)

# Get the Data
dress_data <- data.frame(read_csv(file = "data/uciml_dress_attribute.csv",na=c("null",NA)))
str(dress_data)

# EDA
sum(is.na(dress_data)) # 821 
colSums(is.na(dress_data)) 

# Preliminary observations
# 821 missing values. # Max missing values in vars FabricType, Decoration, Pattern.Type, waiseline, material
# recode the column names to lower case. 
# rename var waiseline to waistline
# rename var Pattern.Type to patterntype

