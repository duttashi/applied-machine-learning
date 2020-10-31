# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 14:56:08 2020

Objective: Predict future sales
@author: Ashish
"""

# Load required libraries
import pandas as pd
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import seaborn as sns
# load the data
features_df = pd.read_csv("../../data/walmart-sales/walmart_features.csv")
stores_df = pd.read_csv("../../data/walmart-sales/walmart_stores.csv")
train_df = pd.read_csv("../../data/walmart-sales/walmart_train.csv")
test_df = pd.read_csv("../../data/walmart-sales/walmart_test.csv")

# Basic summary statistics
print("features shape: ",features_df.shape)
print("stores shape: ", stores_df.shape)
print("train shape: ", train_df.shape)
print("test shape", test_df.shape)
print("features columns", features_df.columns)
print("stores columns", stores_df.columns)
print("train columns", train_df.columns)
print("test columns", test_df.columns)

# merge the store and features dataframe together
store_features_df = stores_df.merge(features_df, how = "inner", on = "Store")
print(store_features_df.head())
print(store_features_df.describe())
print(train_df.head())

# # print the top 10 departments in training data
# top10_dept_lbl = train_df['Dept'].value_counts()[:10].index # Taking the top 10 index
# top10_dept_vals = train_df['Dept'].value_counts()[:10].values # Taking the top 10 values

# print(top10_dept_lbl, top10_dept_vals)
# print(store_features_df.info())
# print(train_df.info())
# print(test_df.info())

# convert Date into Date format
store_features_df['Date'] = pd.to_datetime(store_features_df['Date'])
train_df['Date'] = train_df[['Date']].apply(pd.to_datetime)
test_df['Date'] = test_df[['Date']].apply(pd.to_datetime)
print(store_features_df.info())
print(train_df.info())
print(test_df.info())

# Feature engineering
# get the week and year from the Date in store_features dataframe
store_features_df['Weeks'] = store_features_df.Date.dt.week
store_features_df['Year'] = store_features_df.Date.dt.year
print(store_features_df.head())

# merge the store_features dataframe with the train dataset
train_df_merge = train_df.merge(store_features_df, how = "inner", on = ["Store",'Date','IsHoliday']).sort_values(by=["Store",'Dept', 'Date']) 
print(train_df_merge.head())
# merge the store_features dataframe with the test dataset
test_df_merge = test_df.merge(store_features_df, how = "inner", on = ["Store",'Date','IsHoliday']).sort_values(by=["Store",'Dept', 'Date']) 
print(test_df_merge.head())

# EDA
# Correlation matrix
# Average weekly sales for year 2010
weekly_sales_2010 = train_df_merge[train_df_merge['Year']=='2010']['Weekly_Sales'].groupby(train_df_merge['Weeks']).mean()
print(weekly_sales_2010.head())

# Plot the weekly sales data
sns.lineplot(data=weekly_sales_2010, x= weekly_sales_2010.index, y=weekly_sales_2010.values)