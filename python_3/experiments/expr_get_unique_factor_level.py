# -*- coding: utf-8 -*-
"""
Created on Fri Oct  8 11:02:08 2021
Objective: Given a dataframe, Get a list of categories for categorical variable
@author: Ashish
"""

# load required libraries
import pandas as pd
import numpy as np

# create some fake data
a = ['arrived','departed','delayed']
df = pd.DataFrame(np.random.choice(a, size=(10,3)), 
                  columns = ['Col1','Col2','Col3'])
print(df)
print(df.dtypes)

# coerce object data type to categorical format
df['Col1'] = pd.Categorical(df['Col1'])
print(df.dtypes)

# show unique categoris
print(df['Col1'].unique())



