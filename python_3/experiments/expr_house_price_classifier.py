# -*- coding: utf-8 -*-
"""
Created on Tue Oct 20 13:35:47 2020

@author: Ashish
"""

import pandas as pd

dataPath = "../data/housing.csv"
data = pd.read_csv(dataPath)
print(data.head())
print(data.info())
print( data['ocean_proximity'].value_counts() )