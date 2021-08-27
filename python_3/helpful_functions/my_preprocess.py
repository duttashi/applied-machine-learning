# -*- coding: utf-8 -*-
"""
Created on Mon Sep 21 08:21:18 2020

@author: Ashish
"""
import pandas as pd
import numpy as np
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
    total_missing = df.isnull().sum().sort_values(ascending=False)
    percent_missing = round( df.isnull().sum() * 100 / len(df), 3)
    missing_value_df = pd.DataFrame({'Variable': df.columns,
                                     'Total': total_missing,
                                     'Percent missing': percent_missing}
                                    )
    
    return missing_value_df

# rearrange dataframe by separating categorical & continuous variables
def rearrange_dataframe(df):
    # find all categorical cols
    # print(df.dtypes)
    catCols = [col for col in df.columns if df[col].dtypes == 'O']
    numCols = [col for col in df.columns if df[col].dtypes == np.float64 or df[col].dtypes == np.int64]
    # concatenate both lists
    allCols = catCols + numCols
    df_rearranged = df[allCols]
    
    return df_rearranged

def impute_missing(df):
    # function to impute missing data
    # median imputation for continuous & mode imputation for categorical
    # Input: data frame Output: imputed dataframe
    # median impute for continuous variables
    # print("\n missing data before imputation\n", df.isnull().sum())
    numCols = [col for col in df.columns if df[col].dtypes == np.float64]
    catCols = [col for col in df.columns if df[col].dtypes == 'O']
    df[numCols] = lambda x: x.fillna(x.median())
    df[catCols] = lambda x: x.fillna(x.mode())
    
    # return imputed dataframe
    return df