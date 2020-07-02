# -*- coding: utf-8 -*-
"""
Created on Thu Jul  2 17:40:28 2020

@author: Ashish
Objective: To predict the price-range of mobile phones
Data Source: https://www.kaggle.com/prajwal17/mobile-price-prediction-project?
"""
# load the required libraries
import pandas as pd
# import os
# print(os.getcwd())

# Now read the data and store it in a dataframe
mobile_train_data = pd.read_csv("../../data/data_train_kaggle_mobile_price.csv")
mobile_test_data = pd.read_csv("../../data/data_test_kaggle_mobile_price.csv")
# describe the data
# print(mobile_train_data.describe)
# print(mobile_test_data.describe)
# print(mobile_train_data.head())
# print(mobile_train_data.columns)

# check for missing values
print(mobile_train_data.isnull().sum()) # no missing data

# select all columns except one. See this SO thread https://stackoverflow.com/questions/29763620/how-to-select-all-columns-except-one-column-in-pandas
X = mobile_train_data.loc[:, mobile_train_data.columns != 'price_range']
y = mobile_train_data.loc[:, mobile_train_data.columns == 'price_range']

# Feature selection by determining feature importance
from sklearn.tree import DecisionTreeClassifier

tree = DecisionTreeClassifier().fit(X, y)
print(tree.feature_importances_)


