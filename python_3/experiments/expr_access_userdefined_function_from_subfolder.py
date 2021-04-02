# -*- coding: utf-8 -*-
"""
Created on Fri Apr  2 13:47:46 2021

@author: Ashish
"""

from helpful_functions.func_uniques import return_uniques
import pandas as pd

# load data
df = pd.read_csv("../../data/kaggle_uciml_heart.csv")

uniqueVals = return_uniques(df)
print("unique values", uniqueVals)
