# -*- coding: utf-8 -*-
"""
Created on Sat Jun 27 20:54:51 2020
https://medium.com/@hiromi_suenaga/machine-learning-1-lesson-1-84a1dc2b5236

"""
# install required packages
# pip install pandas-summary

from pandas_summary import DataFrameSummary
#from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import *
from sklearn import metrics
import os
import pandas as pd
import numpy as np
from fastai.imports import*
#from fastai.structured import *
from fastai.tabular import *
from fastai.structured import *
from IPython.display import display

DATA_PATH = "C:\\Users\\Ashoo\\Documents\\playground_r\\applied-machine-learning\\python_3\\kaggle_bulldozer\\"

# print current work directory 
#print(os.getcwd())

# set working directory
os.chdir(DATA_PATH)
# print(os.getcwd())
# print list of files in DATA_PATH
#print(os.listdir(DATA_PATH))

# read the data 
df_raw = pd.read_csv("data//Train.csv", low_memory=False, parse_dates=["saledate"])

#print(df_raw.head().transpose())

# take a log of the predictor variable, the Sale Price
df_raw.SalePrice = np.log(df_raw.SalePrice)
#print(df_raw.SalePrice)

## Initial data preprocessing
m = RandomForestRegressor(n_jobs = -1)
#m.fit(df_raw.drop('SalePrice', axis=1), df_raw.SalePrice)
# convert categorical to continuous format
add_datepart(df_raw, 'saledate')
# print(df_raw.saleYear.head())
# print(df_raw.columns)

# convert categorical data to continuous
train_cats(df_raw)
print(df_raw.UsageBand.cat.categories)
# reorder the categories
df_raw.UsageBand.cat.set_categories(['High', 'Medium', 'Low'],
                                    ordered=True, inplace=True)
def display_all(df):
    with pd.option_context("display.max_rows", 1000): 
        with pd.option_context("display.max_columns", 1000): 
            display(df)

display_all(df_raw.isnull().sum().sort_index()/len(df_raw))

df, y, nas = proc_df(df_raw, 'SalePrice')

# Build model
m = RandomForestRegressor(n_jobs=-1)
m.fit(df, y)
print(m.score(df,y))
