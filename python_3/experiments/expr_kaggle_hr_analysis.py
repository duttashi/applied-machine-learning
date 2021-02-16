# -*- coding: utf-8 -*-
"""
Created on Tue Feb 16 10:40:40 2021
Data source: https://www.kaggle.com/arashnic/hr-analytics-job-change-of-data-scientists
Objective: Predict the probability of a candidate looking for a new job
@author: Ashish
"""
# required libraries
import pandas as pd

# read the data
df_train = pd.read_csv("../../data/kaggle_hr_analytic_train.csv")

# EDA
print(df_train.shape)
# check for missing values
print("missing value count: ")
print(df_train.isnull().sum())
print(df_train.dtypes)
# missing value imputation
from sklearn.impute import SimpleImputer
imp = SimpleImputer(strategy='most_frequent' )
df_cmplt = pd.DataFrame(imp.fit_transform(df_train)) # impute the missing va;ues then convert to dataframe
df_cmplt.columns = df_train.columns
df_cmplt.index = df_train.index
print(df_cmplt.isnull().sum())
print(df_train.dtypes)

