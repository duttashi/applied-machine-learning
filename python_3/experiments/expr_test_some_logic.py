# -*- coding: utf-8 -*-
"""
Created on Wed Sep  8 14:32:31 2021

@author: Ashoo
"""

import pandas as pd
import numpy as np

df = {'id':[1,2,3,4,5],
      'name':['abc','','bash','','mango'],
      'age': ['',20,'',34,''],
      'salary':[100,'',200,'',300]
      }

df = pd.DataFrame(df).set_index(keys='id')
print(df)

# replace blank with nan
df = df.replace(r'^\s*$', np.nan, regex=True)
# print()

for col in df.columns:
    if(df[col].dtype == 'object'):
        df[col] = df[col].fillna(df[col].mode()[0])
    elif (df[col].dtype == 'int64'):
        df[col] = df[col].fillna(df[col].median()[0])
    else:
        continue
print(df)