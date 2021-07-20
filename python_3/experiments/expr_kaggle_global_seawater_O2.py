# -*- coding: utf-8 -*-
"""
Created on Tue Jul 20 10:30:04 2021
# reference: https://www.kaggle.com/tjkyner/global-seawater-oxygen18-levels
@author: Ashish
"""

# required libraries
import pandas as pd
import numpy as np
#import seaborn as sns
import matplotlib.pyplot as plt

# load dataset
df = pd.read_csv("../../data/kaggle_gso18.csv",
                 dtype = {'Year':'category',
                          'month':'category'})
print("data shape: ",df.shape,
      "\n","Variable names:\n",df.columns,
      "\nVariable data types: ",df.dtypes)

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

## change data type

df[['pTemperature','Salinity','d18O']] = df[['pTemperature','Salinity','d18O']].astype(float)
df[['Year','Month']] = df[['Year','Month']].astype(str)
# df = df.astype({int_cols: int})
print(df.dtypes)

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

## missing values
labels = []
values = []
print("\n## Count of missing values per column")
for col in df.columns:
    labels.append(col)
    values.append(df[col].isnull().sum())
    print(col, ": ",values[-1])

# Missing value visuals
# ind = np.arange(len(labels))
# width = 0.9
# fig, ax = plt.subplots(figsize=(12,50))
# rects = ax.barh(ind, np.array(values), color='y')
# ax.set_yticks(ind+((width)/2.))
# ax.set_yticklabels(labels, rotation='horizontal')
# ax.set_xlabel("Count of missing values")
# ax.set_title("Number of missing values in each column")
# #autolabel(rects)
# plt.show()


# Univariate plots
plt.figure(figsize=(16,10), dpi= 80)
plt.plot('Salinity', data=df, color='tab:blue')
plt.show()

plt.figure(figsize=(16,10), dpi= 80)
plt.plot('pTemperature', data=df)
plt.show()

plt.figure(figsize=(16,10), dpi= 80)
plt.plot('d18O', data=df, color='tab:blue')
plt.show()

plt.figure(figsize=(16,10), dpi= 80)
plt.plot('Year', data=df)
plt.show()

df.plot.scatter(x='Year', y='Salinity', color='red')


# Distribution plot:
# Now let us look at the distribution plot of some of the numeric variables.

# cols_to_use = ['Depth','pTemperature','Salinity','d180']
# fig = plt.figure(figsize=(8, 20))
# plot_count = 0
# for col in cols_to_use:
#     plot_count += 1
#     plt.subplot(4, 1, plot_count)
#     plt.plot(range(df.shape[0]), df[col].values)
#     plt.title("Distribution of "+col)
# plt.show()


# df = df[, float_cols].astype(int)

# plt.plot('Year','Depth', data= df)