# -*- coding: utf-8 -*-
"""
Created on Fri Jul 10 18:10:07 2020

@author: Ashish
"""


import pandas as pd
from pandas import Series, DataFrame
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
#% matplotlib inline

#print(os.getcwd())
titanic_df = pd.read_csv("../../data/kaggle_titanic_train.csv"
                         , low_memory=False)
print(titanic_df.head())
print(titanic_df.info())

sns.catplot(y="Sex", data = titanic_df, hue = 'Pclass')
