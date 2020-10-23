# -*- coding: utf-8 -*-
"""
Created on Fri Oct 23 15:12:12 2020
Objective: Use column transformer to apply different preprocessing to different columns
Reference: https://www.youtube.com/watch?v=NGq8wnH5VSo&list=PL5-da3qGB5ID7YYAqireYEew2mWVvgmj6&index=1&ab_channel=DataSchool
@author: Ashish
"""

# create dataframe
import pandas as pd

data = {"Fare":[7.25,71,89,45,57,78],
        "Embarked":['S','C','S','S','S','Q'],
        'Sex':['male','female','female','female','male','male'],
        'Age':[22,38,26,35,35,"NaN"]
        }
df = pd.DataFrame(data = data)
print(df)

from sklearn.preprocessing import OneHotEncoder
from sklearn.impute import SimpleImputer
from sklearn.compose import make_column_transformer

ohe = OneHotEncoder() # this method will perform One hot encoding on categorical vars
imp = SimpleImputer() # this method will impute the missing values

# Using column name for column transformation
col_transfrm = make_column_transformer((ohe, ['Embarked','Sex']),
                                       (imp, ['Age']),
                                       remainder = 'passthrough')
# Always apply fit_transform() for variable transformation only
print(col_transfrm.fit_transform(df))

# Using column selector for column transformation
from sklearn.compose import make_column_selector
ct = make_column_transformer((ohe,[1,2]))
print(ct.fit_transform(df))

