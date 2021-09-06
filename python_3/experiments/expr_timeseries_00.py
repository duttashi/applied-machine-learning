# -*- coding: utf-8 -*-
"""
Created on Mon Sep  6 10:45:24 2021
Objective: To practise time series data analysis
@author: Ashish
"""

# load libraries
import pandas as pd
import matplotlib.pyplot as plt

# load data
df = pd.read_csv("../../data/kaggle_housepricesale.csv", 
                 index_col='datesold', parse_dates= ['datesold'])
# data summary
print("Data shape: ", df.shape)
print("Row count: ", df.shape[0])
print("Columns count: ", df.shape[1])

# lowercase all column names
df.columns = [x.lower() for x in df.columns]
print(df.columns)
# check missing
cols_missing_vals = [col for col in df.columns if df[col].isnull().any()]
print("cols with missing values\n", cols_missing_vals)

# Plots
plt.style.use('fivethirtyeight')

df['price'].plot()
plt.title('House price over monthly time frquency')
plt.show()

df['price'].plot()
shifted = df['price'].shift(5).plot(legend=True)
shifted.legend(['price','price_lagged'])
plt.show()



