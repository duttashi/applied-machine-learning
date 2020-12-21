# -*- coding: utf-8 -*-
"""
Created on Thu Dec 10 14:42:53 2020

@author: Ashish
dataset source: https://www.kaggle.com/altruistdelhite04/loan-prediction-problem-dataset
"""

import pandas as pd


# dataPath = "../../data/BankChurners.csv"
train_data = pd.read_csv("../../data/kaggle_credit_approval_train.csv")
test_data = pd.read_csv("../../data/kaggle_credit_approval_test.csv")

# EDA

# merge the train and test dataframes
df = pd.concat([test_data.assign(ind="test_data"), train_data.assign(ind="train_data")])

# split dataframe into train & test
# test, train = df[df["ind"].eq("test_data")], df[df["ind"].eq("train_data")]

print(df.columns)
print(df.shape)
# function for data cleaning
def clean_header(df):
    """
	This functions removes weird characters and spaces from column names, while keeping everything lower case
	"""
    df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('(', '').str.replace(')', '')
    return df

df1 = clean_header(df)
print(df1.columns)