# -*- coding: utf-8 -*-
"""
Created on Sun May 24 15:54:31 2020

@author: Ashish
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

# read the data
#print(os.getcwd())
df = pd.read_csv("../../data/housing.csv")
print(df.head())
# get data description
print(df.info()) # only the ocean_proximity variable is categorical
# describe() method shows a summary of the numerical attributes
print(df.describe)
print(df['ocean_proximity'].value_counts())
df.hist(bins=50, figsize=(20,15))
plt.show()

# create a function to split the data into train and test set
def split_train_test(data, split_ratio):
    shuffled_indices = np.random.permutation(len(data))
    test_set_size = int(len(data)*split_ratio)
    train_data = shuffled_indices[test_set_size:]
    #print(len(train_data))
    test_data = shuffled_indices[:test_set_size]
    #print(len(test_data))
    return data.iloc[train_data], data.iloc[test_data]

# call the function
train_set, test_set = split_train_test(df, 0.2)
print(len(train_set),"train +", len(test_set),"test")
