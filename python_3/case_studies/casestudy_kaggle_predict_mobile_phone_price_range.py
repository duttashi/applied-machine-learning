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

print("\nTraining data shape: ", X.shape)
print("\nTesting data shape: ", y.shape)

# Feature selection by determining feature importance
# from sklearn.tree import DecisionTreeClassifier
# tree = DecisionTreeClassifier().fit(X, y)
# print(tree.feature_importances_)

# Feature selection by removing features with low variance
# motivated by the fact that low variance features contain less iformation
# calculate variance of each feature then drop features with variance below some pre-specified thereshold
# make sure features have the same scale
from sklearn.feature_selection import VarianceThreshold 

# create custom function for feature selection
def VarianceThreshold_selector(data):
    selector = VarianceThreshold(threshold=0.8)
    selector.fit(data)
    return(data[data.columns[selector.get_support(indices=True)]])

# Conduct variance thresholding
X_high_variance = VarianceThreshold_selector(X)
print("\nHigh variance data shape: ", X_high_variance.shape)
print("Features with high variance are: \n",X_high_variance.columns)

