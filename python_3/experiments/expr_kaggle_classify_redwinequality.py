# -*- coding: utf-8 -*-
"""
Created on Mon Aug 23 12:36:26 2021
Dataset source: kaggle
@author: Ashish
"""
from pandas import read_csv
import seaborn as sns
import matplotlib.pyplot as plt
# load data
df = read_csv('../../data/kaggle-winequality-red.csv')
# describe data
print("\n Data shape: ", df.shape)
print("\n Data types\n", df.dtypes)
print("\n missing vals: ", df.isnull().sum())
print("\n Mean of missing values:\n ", df.isnull().mean())

# data management

# lowercase all column names
df.columns = [x.lower() for x in df.columns]

# univariate plots
fig = plt.figure(figsize=(10,6))
sns.barplot(x= 'quality', y= 'alcohol', data=df)




