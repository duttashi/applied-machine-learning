# Script create date:
# Problem statement: Create a classification model to predict find out the sales of each product at a particular store so that it would help the decision makers at BigMart to find out the properties of any product or store, which play a key role in increasing the overall sales.
# Reference: Big Mart Sales practice problem https://trainings.analyticsvidhya.com/courses/course-v1:AnalyticsVidhya+BigMS01+2018_1/courseware/0adf11d500c84ca586e6adf2950ff91a/1b7eb96a08824011929e64fe248a8cd5/?activate_block_id=block-v1%3AAnalyticsVidhya%2BBigMS01%2B2018_1%2Btype%40sequential%2Bblock%401b7eb96a08824011929e64fe248a8cd5

# Load required libraries
library(data.table) # used for reading and manipulation of data
library(dplyr)      # used for data manipulation and joining
library(ggplot2)    # used for ploting 
library(caret)      # used for modeling
library(corrplot)   # used for making correlation plot
library(xgboost)    # used for building XGBoost model
library(cowplot)    # used for combining multiple plots 

# load data
getwd()
train = fread("big mart sales-prediction\\data\\Train.csv") 
test = fread("big mart sales-prediction\\data\\Test.csv")
submission = fread("big mart sales-prediction\\data\\samplesubmission.csv")

# Understanding the data
## check dimension
dim(train)
dim(test)
## features
names(train)
names(test)
## structure
str(train)
str(test)

# combine train and test
test[,Item_Outlet_Sales := NA]
combi = rbind(train, test) # combining train and test datasets
dim(combi)

# Visualisation for relationship detection

## Target variable is continuous: so visualise it using histogram
ggplot(train) + geom_histogram(aes(train$Item_Outlet_Sales), binwidth = 100, fill = "darkgreen") +
  xlab("Item_Outlet_Sales")
# seems max item outlet sales are between 0 to 5000
# it is a right skewd variable and would need some data transformation to treat its skewness.

## Plotting other independent continuous vars
p1 = ggplot(combi) + geom_histogram(aes(Item_Weight), binwidth = 0.5, fill = "blue")
p2 = ggplot(combi) + geom_histogram(aes(Item_Visibility), binwidth = 0.005, fill = "blue")
p3 = ggplot(combi) + geom_histogram(aes(Item_MRP), binwidth = 1, fill = "blue")
plot_grid(p1, p2, p3, nrow = 1) # plot_grid() from cowplot package

# Observations
# 
# There seems to be no clear-cut pattern in Item_Weight.
# Item_Visibility is right-skewed and should be transformed to curb its skewness.
# We can clearly see 4 different distributions for Item_MRP. It is an interesting insight.

