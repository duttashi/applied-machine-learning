# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 07:34:31 2020
Develop several custom fuctions for data preprocessing.

@author: Ashish
"""

# Implementation
import pandas as pd
from my_preprocess import percent_value_counts 
# read the data
df = pd.read_csv("../../data/adult.csv")
print(df.columns)
# find percent value counts for variable hours.per.week
workhours = percent_value_counts(df, 'hours.per.week')
print(workhours)