# -*- coding: utf-8 -*-
"""
Created on Sun Oct 25 08:12:59 2020

@author: Ashish
"""

# load the required libraries
import pandas as pd

# load the required data
df = pd.read_csv("../../data/adult.csv")
# Exploratory data analysis
##  look at data shape, number of cols, column type, missing vals etc
print("Original data shape: ",df.shape)
print(df.columns)
print(df.head)
# Observations: assign column names, remove irrelevant cols
col_header = ['age','workclass','fnlwgt','education','education-num',
              'marital-status','occupation','relationship','race','sex',
              'capital-gain','capital-loss','hours-per-week','native-country','salary']
# assign column headers
df.columns = col_header
print(df.columns)

# remove irrelevant cols based on theri index number
# NOTE: Pandas column indexing begins from ZERO and not from One.
drop_cols = [2,4,10,11]
df.drop(df.columns[drop_cols],axis=1,inplace=True)
print("reduced data shape: ", df.shape)
print("reduced data columns: ",df.columns)

# check for missing values
print("missing value count: ")
print(df.isnull().sum()) # No missing values

# convert categorical cols to numerical format

# 1. check for column data types
print("Column data types: ",df.dtypes)
# 2. Convert selected object data types to category data type
cat_cols = ['workclass','education','marital-status','occupation','relationship','race','sex','native-country','salary']
# 2. select all categorical columns using select.dtypes()
df = df[cat_cols].astype('category')
print("Revised column data types ", df.columns)
# check for high correlated variables
