# -*- coding: utf-8 -*-
"""
Created on Thu Sep  2 16:15:31 2021
dataset source: https://www.kaggle.com/tejashvi14/engineering-placements-prediction
objective: predict which student will get placement
problem type: binary imbalanced classfier problem
@author: Ashish
"""
# load required libraries
import pandas as pd

# load require data
df = pd.read_csv('../../data/kaggle_collegePlace.csv')
# describe data
print("\n Data shape: ", df.shape)
print("\n Data types\n", df.dtypes)
print("\n missing vals: ", df.isnull().sum())
print("\n Mean of missing values:\n ", df.isnull().mean())

# data management

# lowercase all column names
df.columns = [x.lower() for x in df.columns]
print(df.columns)
# data summary
print(df['gender'].value_counts())
print(df['stream'].value_counts()) # merge CS with IT; merge other stream into engineering

# EDA
# for variable stream create a new variable called faculty
# create a list of all streams
lst_stream_CS = ['Computer Science', 'Information Technology']
# lst_stream = list(df['stream'].unique())
dict1 = dict.fromkeys(lst_stream_CS, 'Computer Science')
lst_stream_ENG = ['Mechanical', 'Electrical', 'Civil','Electronics And Communication']
dict2 = dict.fromkeys(lst_stream_ENG, 'Engineering')

# df['faculty'] = df

d = {**dict1, **dict2}
print(d)
df['faculty'] = df['stream'].map(d)
print(df['faculty'].value_counts())
print(df.head(5))


# print(streams_list)

# map target variable tp words


