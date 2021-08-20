# -*- coding: utf-8 -*-
"""
Created on Fri Aug 20 09:29:53 2021
Data source: https://www.kaggle.com/theforcecoder/new-york-city-corporate-loans
@author: Ashish
"""

# load required libraries
import pandas as pd
from pandas import read_csv
# ignore warning
pd.options.mode.chained_assignment = None  # default='warn'
# load data
df = read_csv('../../data/kaggle_nyc_loans.csv')
# describe data
print("\n Data shape: ", df.shape)
print("\n Data types\n", df.dtypes)
print("\n missing vals: ", df.isnull().sum())
print("\n Mean of missing values:\n ", df.isnull().mean())

# data management

# lowercase all column names
df.columns = [x.lower() for x in df.columns]
# Rename the columns, replace space with underscore
# old_col_names = df.columns.tolist()
# print("\nOld col names:\n", old_col_names)
df.columns = df.columns.str.replace(' ','_')

# filter out missing data greater than 80%
df_missing = df[df.isnull().values.any(axis=1)]
print("\n missing values: ", df_missing.isnull().sum())
# df_1 = df[!df_missing]
df_1 = df[df.columns[df.isnull().mean() < 0.8]]
# print("\n New Data Frame Mean of missing values: ", df_1.isnull().mean())

# split date into 3 columns
# print(df.dtypes)
# convert object dates to date format
# df['fiscal_year'] = df['fiscal_year_end_date']
df_1['fiscal_year_end_date'] = pd.to_datetime(df_1['fiscal_year_end_date'],
                                            format="%m/%d/%Y")
df_1['date_loan_awarded'] = pd.to_datetime(df_1['date_loan_awarded'],
                                          format="%m/%d/%Y")

# create new columns
df_1['fsend_year'] = df_1['fiscal_year_end_date'].dt.year
df_1['fsend_month'] = df_1['fiscal_year_end_date'].dt.month
df_1['fsend_day'] = df_1['fiscal_year_end_date'].dt.day

df_1['lnawrd_year'] = df_1['date_loan_awarded'].dt.year
df_1['lnawrd_month'] = df_1['date_loan_awarded'].dt.month
df_1['lnawrd_day'] = df_1['date_loan_awarded'].dt.day

# drop columns
df_1.drop(['fiscal_year_end_date','date_loan_awarded'], axis=1, inplace=True)
print(df_1.columns)
print(df_1.shape)
# print(df['fsend_year'].head(5))
# print(df_1['lnawrd_year'].tail(5))
print("\n missing values:\n ", df_1.isnull().mean())


