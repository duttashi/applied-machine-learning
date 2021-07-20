# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 10:30:04 2021
# reference: https://www.kaggle.com/tjkyner/global-seawater-oxygen18-levels
@author: Ashish
"""

# required libraries
import pandas as pd
import numpy as np
import seaborn as sns

# load dataset
df = pd.read_csv("../../data/kaggle_gso18.csv",
                 dtype = {'Year':'category',
                          'month':'category'})
print("data shape: ",df.shape,
      df.head(5), "\n","Variable\n",df.columns,
      "Variable data types:\n",df.dtypes)

# Data management/cleaning

## drop col reference & delme
df.drop(['Reference','delme'], axis=1, inplace= True)
print(df.shape)
print(df.columns)
## replace ** with NA
df['pTemperature'].replace('**',np.nan, inplace=True)
df['Salinity'].replace('**',np.nan, inplace= True)
df['d18O'].replace('**',np.nan, inplace= True)
df['dD'].replace('**',np.nan, inplace= True)
df['Year'].replace('**',np.nan, inplace= True)
df['Month'].replace('**',np.nan, inplace= True)

# show cols with missing values
print("Cols with missing values:\n",df.columns[df.isnull().any()])
percent_missing = df.isnull().sum() * 100 / len(df)
missing_value_df = pd.DataFrame({'column_name': df.columns,
                                  'percent_missing': percent_missing})
print(missing_value_df)
#print(df.columns[df.isnull().any()].tolist())
# drop columns with more than 80% missing data
df=df.drop(['dD'], axis=1)
print(df.shape)

# filter missing vavlues
# filtered_df = df[df[['pTemperature', 'Salinity', 'd18O',
#                      'Year','Month']].notnull().all(1)]
# print("\nOriginal data frame shape", df.shape)    
# print("\nFiltered data frame shape", filtered_df.shape)
# write to disk
#df.to_csv("../../data/kaggle_gso18_clean.csv", sep=",")
# Univariate plots
sns.set(style="white", color_codes=True)

sns.distplot(df['pTemperature'])
# sns.relplot(x='Year', y='pTemperature', data = df)
# sns.pairplot(df)
# sns.relplot(x='pTemperature', y='Salinity', data=df_filtr)



