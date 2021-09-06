# -*- coding: utf-8 -*-
"""
Created on Fri Aug 27 10:01:02 2021

@author: Ashish
"""
import pandas as pd
from my_preprocess import find_missing, rearrange_dataframe
from my_preprocess import impute_missing

# read data in global variable
df = pd.read_csv('../../data/kaggle_amstr_houseprice.csv')

# print(df.dtypes)
print(df.info())
df_rearngd = rearrange_dataframe(df)
print(df_rearngd.dtypes)
df_miss = find_missing(df)
print("\nmissing data before imputation\n", df_miss.isnull().sum())
df_clean = impute_missing(df_rearngd)
print("\nmissing data after imputation\n", df_clean.isnull().sum())

