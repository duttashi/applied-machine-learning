# -*- coding: utf-8 -*-
"""
Created on Mon Oct  4 10:16:52 2021

data source: https://www.kaggle.com/varpit94/uber-stock-data
Objective: Time  series data analysis
@author: Ashish
"""

# load required libraries
import pandas as pd
import matplotlib.pyplot as plt
plt.style.use("fivethirtyeight")
# read data in memory
uber = pd.read_csv("../../data/UBER.csv", index_col='Date',
                   parse_dates=['Date'])
print("\nOriginal Data shape",uber.shape)
print(uber.dtypes)
# Plots
uber['Volume'].asfreq('D').plot() # # asfreq method is used to convert a time series to a specified frequency. Here it is monthly frequency.
plt.title("Stock price")
# plt.show()

# uber['2019':'2020'].plot(subplots=True, figsize=(10,12)) # # asfreq method is used to convert a time series to a specified frequency. Here it is monthly frequency.
# plt.title("Monthly Stock price")
# plt.show()

shifted = uber['Volume'].asfreq('D').shift(10).plot(legend=True)
shifted.legend(['Volume','Volume_Lagged'])
plt.show()

uber = uber.resample('3D').mean()
print(uber.head(), "\nResampled Data shape", uber.shape)

# Percent change
uber['Change'] = uber.High.div(uber.High.shift())
uber['Change'].plot(figsize=(20,8))

# Stock returns
uber['Return'] = uber.Change.sub(1).mul(100)
uber['Return'].plot(figsize=(20,8))

# Absolute change in successive rows
uber.High.diff().plot(figsize=(20,6))

print(uber.shape,"\n",uber.head)
  





