# -*- coding: utf-8 -*-
"""
Created on Sat Nov 21 10:11:18 2020
The given program will transform a single column containing categorical vars into boolean values
@author: Ashish
"""

import pandas as pd
from sklearn.preprocessing import OneHotEncoder

df = pd.DataFrame({'EDUCATION':['high school','high school','high school',
                                'university','university','university',
                                'graduate school', 'graduate school','graduate school',
                                'others','others','others']})
print(df)

onehot_encoder = OneHotEncoder(sparse=False)
# print(onehot_encoder)
df1=onehot_encoder.fit_transform(df['EDUCATION'].to_numpy().reshape(-1,1))
print(df1)