# -*- coding: utf-8 -*-
"""
Created on Mon Sep  6 09:32:13 2021

@author: Ashish
"""
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error
# load data
df = pd.read_csv("../../data/kaggle_melb_data.csv")

# data summary
print("Data shape: ", df.shape)
print("Row count: ", df.shape[0])
print("Columns count: ", df.shape[1])
# print("\n Data types\n", df.dtypes)
# print("\n missing vals: ", df.isnull().sum())
# print("\n Mean of missing values:\n ", df.isnull().mean())

# data management

# lowercase all column names
df.columns = [x.lower() for x in df.columns]
print(df.columns)

# Function for comparing different approaches
def score_dataset(X_train, X_valid, y_train, y_valid):
    model = RandomForestRegressor(n_estimators=10, random_state=0)
    model.fit(X_train, y_train)
    preds = model.predict(X_valid)
    return mean_absolute_error(y_valid, preds)


# split data & build model

# select target
y = df.price
# drop target variable
df_selected_cols = df.drop(['price'], axis=1)
# keeping only numeric predictors
X = df_selected_cols.select_dtypes(exclude = 'object')

# approach #1: drop cols with missing data
# check missing
cols_missing_vals = [col for col in df.columns if df[col].isnull().any()]
print("cols with missing values\n", cols_missing_vals)


# Divide data into training and validation subsets
X_train, X_valid, y_train, y_valid = train_test_split(X, y, train_size=0.8, test_size=0.2,
                                                      random_state=0)
print("X train shape: ", X_train.shape)
print("X valid shape: ", X_valid.shape)
print("y train shape: ", y_train.shape)
print("y valid shape: ", y_valid.shape)

# Define Function to Measure Quality of Each Approach









