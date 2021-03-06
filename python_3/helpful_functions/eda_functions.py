# -*- coding: utf-8 -*-
"""
Created on Wed Sep 23 21:48:48 2020
Helpful functions for data cleaning
Note: Python function names as defined in PEP 8 https://www.python.org/dev/peps/pep-0008/#function-and-variable-names
@author: Ashish
Reference: https://www.kaggle.com/gcspkmdr/cross-sell-cv-trees?scriptVersionId=43084700
"""
# import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns 
import pandas as pd
import numpy as np
import random

def data_with_missing_vals():
    df = pd.DataFrame(np.random.randn(5, 3),
                      index=['a', 'b', 'c', 'd', 'e'],
                      columns=['one', 'two', 'three'])
    
    ix = [(row, col) for row in range(df.shape[0]) for col in range(df.shape[1])]
    for row, col in random.sample(ix, int(round(.1*len(ix)))):
        df.iat[row, col] = np.nan
    return df
    

def print_data_head(train_data):
    return train_data.head(5)

def find_null_columns(train_data):
    
    list_of_nullcolumns =[]
    for column in train_data.columns:
        # print(column)
        total= train_data[column].isna().sum()
        try:
            if total !=0:
                print('Total Na values is {0} for column {1}' .format(total, column))
                list_of_nullcolumns.append(column)
        except:
            print(column,"-----",total)
    
    print('\n')
    
    return list_of_nullcolumns

def missing_data_percentage(data):
    
    data_na = (data.isnull().sum() / len(data)) * 100
    
    data_na = data_na.drop(data_na[data_na == 0].index).sort_values(ascending=False)[:30]
    
    return data_na

def missing_data_plot(data_na):
    x = data_na
    fig = plt.figure(figsize=(8, 6))
    plt.plot(x)
    # use plt.show() when the function is not returning a value
    # plt.show()
    # use return plt if the function is returning a plot
    return fig