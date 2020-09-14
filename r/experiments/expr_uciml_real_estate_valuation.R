# Backgroun: The market historical data set of real estate valuation are collected from Sindian Dist., New Taipei City, Taiwan.
# Objective: house price of unit area (10000 New Taiwan Dollar/Ping, where Ping is a local unit, 1 Ping = 3.3 meter squared)
# Evaluation metric # Submissions are evaluated on Root-Mean-Squared-Error (RMSE) between the logarithm of the predicted value and the logarithm of the observed sales price. (Taking logs means that errors in predicting expensive houses and cheap houses will affect the result equally.)
# Dependent variable # SalePrice
# reference # https://archive.ics.uci.edu/ml/datasets/Real+estate+valuation+data+set#


# required libraries
library(tidyverse)
library(data.table) # for setnames()
# clean the workspace
rm(list = ls())
# read data in memory
df<- read.csv("data/uci-ml-real-estate.csv",header=T, 
              na.strings=c("","NA"), stringsAsFactors = FALSE)
# EDA

# 1. Check for missing values
sum(is.na(df))
head(df)
names(df)
# 2. Data Management decisions
## 2.1. rename the cols
df <- df %>%
  setnames(old = names(df), new = c("sno","transact_date","house_age",
                                    "mrt_dist","store_num","lat","lon",
                                    "house_price"))
# Visualization
library(ggplot2)

# 1. relationship between transaction date and location
names(df)
ggplot(data = df, aes(x=lat, y=lon))+
  geom_point(aes(colour=transact_date))
# 2. relationship between house price and location
ggplot(data = df, aes(x=lat, y=lon))+
  geom_point(aes(colour=house_price))
# 3. relationship between house price and number of convenience stores
ggplot(data = df, aes(x=store_num, y=house_price))+
  geom_point(aes(colour=transact_date))
# 4. relationship between house price and distance to station
ggplot(data = df, aes(x=mrt_dist, y=house_price))+
  geom_point()

# Data Modelling

# 1. Multiple Linear regression model
names(df)
# full model - ie taking all vars into consideration
model1 = lm(house_price ~., data = df)
summary(model1) # we can see that vars house age, mrt distance, num of store and lat are significant vars

# residual check for model1
plot(model1, which = 1) # Residuals vs Fitted: The relationship between fitted values and residuals are flat (look at the red line), which indicates the model has linear relationship and the residuals are rougly equal variance across the range of fitted values, this is a sign of homoscedasticity, therefore this assumption is not violated.
plot(model1, which = 2) # Normal Q-Q: The residuals do not fall close to the line (end of the right tail) and there are some deviations from normality, so it is assumed that the residuals are not normally distributed and this assumption is violated.
#Present the Scale-location plot
plot(model1 , which=3) # Scale-location: The red line in this plot is flat and the variances in the square root of the standardized residuals are consistenly across fitted values. Therefore, this is a sign of homoscedasticity and the assumption is not violated.
plot(model1 , which=4)
plot(model1 , which=5) # Residuals vs. Leverage: There is no values that fall in the upper and lower right hand side of the plot beyong the red bands, therefore there is no evidence of influential cases.

#H0:Errors are normally distributed
#H1:Errors are not normally distributed
shapiro.test(model1$residuals) # Since p-value is less than 0.05, it is significant to reject the H0 and which means the errors are not normally distributed. Hence the assumption of normality is violated.

#H0:Errors are uncorrelated.
#H1:Errors are autocorrelated.
durbinWatsonTest(model1)
