# -*- coding: utf-8 -*-
"""
Created on Wed Feb  3 11:02:29 2021
Motivation: https://stackoverflow.com/questions/19960077/how-to-filter-pandas-dataframe-using-in-and-not-in-like-in-sql?rq=1
Reference: https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.isin.html
@author: Ashish
"""

import pandas as pd

# create some data
df = pd.DataFrame({'num_legs': [2, 4], 'num_wings': [2, 0]},
                  index=['falcon', 'dog'])
print(df)

# which animals have 0 or 2 legs or wings?
print(df.isin([0, 2]))