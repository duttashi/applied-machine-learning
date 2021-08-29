# -*- coding: utf-8 -*-
"""
Created on Wed Aug 25 12:43:20 2021
Data source: https://www.kaggle.com/thomasnibb/amsterdam-house-price-prediction
@author: Ashish
"""
# import required libraries
import pandas as pd
import seaborn as sns

# read data in global variable
df = pd.read_csv('../../data/kaggle_amstr_houseprice.csv')

# impute missing values



def preprocess(data = df):
    
    # describe data
    print("\n Data shape: ", df.shape)
    print("\n Data types\n", df.dtypes)
    print("\n missing vals: ", df.isnull().sum())
    print("\n Mean of missing values:\n ", df.isnull().mean())
    
    # data management
    
    # lowercase all column names
    df.columns = [x.lower() for x in df.columns]
       
    # filter out missing data greater than 80%
    df_missing = df[df.isnull().values.any(axis=1)]
    print("\n missing values: ", df_missing.isnull().sum())
    clean_df = df.dropna()
          
    return clean_df

def univariate_visuals(data = df):
    sns.set(color_codes = True)
    sns.displot(data=df, x='price', binwidth=3)
        
    return

def bivariate_visuals(data = df):
    sns.set(color_codes = True)
    sns.jointplot(data=df, x='price', y='area')
    # sns.pairplot(df)
    return

if __name__ == "__main__":
    clean_df = preprocess(df)
    print(type(clean_df))
    print("\n clean dataframe",clean_df.isnull().mean())
    univariate_visuals(clean_df)
    bivariate_visuals(clean_df)
