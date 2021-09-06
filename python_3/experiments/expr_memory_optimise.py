# -*- coding: utf-8 -*-
"""
Created on Sun Sep  5 15:52:15 2021
Objective: Memory optimisation and preprocessing handy features
Reference: https://www.kaggle.com/shravankoninti/python-data-pre-processing-handy-tips
@author: Ashish
"""

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

# load data
df = pd.read_csv("../../data/kaggle_pimadiabetes.csv")
print(df.head())
print(df.dtypes)

memory = df.memory_usage()
print(memory)
print("Total Memory Usage = ",sum(memory))

# memory optimisation.
df.iloc[:,0:9] = df.iloc[:,0:9].astype('float16')
memory = df.memory_usage()
print(memory)
print("Total Memory Usage = ",sum(memory))

# check for outliers
fig, axs = plt.subplots()
sns.boxplot(data=df,orient='h',palette="Set2")
plt.show()

# dealing with outliers
q75, q25 = np.percentile(df["Insulin"], [75 ,25])
iqr = q75-q25
print("IQR",iqr)
whisker = q75 + (1.5*iqr)
print("Upper whisker",whisker)

df["Insulin"] = df["Insulin"].clip(upper=whisker)
fig, axs = plt.subplots()
sns.boxplot(data=df,orient='h',palette="Set2")
plt.show()


