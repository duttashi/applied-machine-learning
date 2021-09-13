# -*- coding: utf-8 -*-
"""
Created on Mon Sep 13 16:02:50 2021
Analysing prek12-higher ed data
@author: Ashish
"""
import pandas as pd

# read data
path = '../../data/learnplatform-covid19-impact-on-digital-learning/'
df_PreK12HigEd = pd.read_csv(path+"df_PreK12HigEd.csv")
print(df_PreK12HigEd.shape,"\n", df_PreK12HigEd.columns)
print("\n product\tool usage")
print(df_PreK12HigEd.value_counts(['prod_name']))


