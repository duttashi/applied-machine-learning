# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 08:21:18 2020

@author: Ashish
"""
import pandas as pd
# def percent_value_counts(df, feature):
#     """This function takes in a dataframe and a column and finds the percentage of the value_counts"""
#     percent = pd.DataFrame(round(df.loc[:,feature].value_counts(dropna=False, normalize=True)*100,2))
#     ## creating a df with th
#     total = pd.DataFrame(df.loc[:,feature].value_counts(dropna=False))
#         ## concating percent and total dataframe
    
#     total.columns = ["Total"]
#     percent.columns = ['Percent']
#     return pd.concat([total, percent], axis = 1)

def find_missing(df):
    # find variable with 90% missing data, filter them out
    # impute continuous with median and categorical with mode
    percent_missing = round( df.isnull().sum() * 100 / len(df), 3)
    missing_value_df = pd.DataFrame({'column_name': df.columns,
                                     'percent missing': percent_missing}
                                    )
    
    return missing_value_df