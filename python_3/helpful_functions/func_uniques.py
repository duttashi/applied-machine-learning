# -*- coding: utf-8 -*-
"""
Created on Fri Apr  2 13:44:41 2021
Function: To return unique values in dataframe
Input: pandas dataframe
Returns: unique values in dataframe
@author: Ashish
"""
def return_uniques(df):
    return df.apply(lambda x: [x.unique()])


