# -*- coding: utf-8 -*-
"""
Created on Wed Sep 23 22:00:08 2020

@author: Ashish
"""
# import sys
# sys.path.append('../') # use the sys.path.append() to call functions from another directory
from helpful_functions.eda_functions import print_data_head, find_null_columns,data_with_missing_vals
from helpful_functions.eda_functions import missing_data_plot

# create a dataframe with some missing values
df = data_with_missing_vals()
print(df)
x = find_null_columns(df)
y = print_data_head(df)
print("Data head are\n",y)
# y = missing_data_plot(df)
print("Null columns are:",x)
# missing_data_plot(df)

fig = missing_data_plot(df)
fig