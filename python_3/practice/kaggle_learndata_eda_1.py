# -*- coding: utf-8 -*-
"""
Created on Wed Sep  8 16:18:51 2021
data source: https://www.kaggle.com/c/learnplatform-covid19-impact-on-digital-learning/data
reference: https://www.kaggle.com/ruchi798/covid-19-impact-on-digital-learning-eda-w-b#Reading-data-files-%F0%9F%91%93
Required script: kaggle_learndata_eda.py
Objective: read the imputed data files and explore them further
@author: Ashish
"""
import pandas as pd
import re
# import matplotlib.pyplot as plt
# import seaborn as sns

df_products = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_products.csv")
df_districts = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_district.csv")
# df_engage = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_engage.csv")

# lowercase column names
df_products.columns = [x.lower() for x in df_products.columns]
df_districts.columns = [x.lower() for x in df_districts.columns]
# df_engage.columns = [x.lower() for x in df_engage.columns]
# print("\n#### Column Names\n")
# print(df_districts.columns)
# print(df_districts.head(3))
# print(df_products.isnull().sum())
# print(df_districts.isnull().sum())
# print(df_engage.isnull().sum())
# print("Products")
# print(df_products.columns)
# print("Districts")
# print(df_districts.columns)
# print("Engagement")
# print(df_engage.columns)

# def columns_to_lowercase(dataframe):
#     dataframe.columns = map(str.lower, dataframe.columns)
#     return dataframe


# # drop duplicates
# current=len(df_engage)
# print('Rows of data before Deleting ', current)
# df_products = df_engage.drop_duplicates()
# print('Rows of data after Deleting ', len(df_engage))
# No duplicates found in data

## Univariate data visuals
# plt.figure(figsize=(12,10))
# sns.countplot(df_districts.state)
# plt.xticks(rotation=90)
# plt.show()

# sns.countplot(data= df_districts, x = "pct_black/hispanic")
# plt.show()

# sns.boxplot(x="pp_total_raw", y="state", data= df_districts)
# plt.show()


# print(df_districts['pct_black/hispanic'].head(3))

## 11/sept/2021

def clean_pct_hisp(column):
    pattern = r'\[\d\,[^\d]'
    txt1 = re.sub(pattern, "",column)
    txt2 = re.sub('\[',"",txt1)
    return txt2

def clean_pct_free(column):
    pattern = r'\[\d\D\d\D[^\d]'
    txt1 = re.sub(pattern, "",column)
    txt2 = re.sub('\[',"",txt1)
    return txt2

def clean_cntry_ratio(column):
    pattern = r'\[\d\D\d*\D*'
    txt1 = re.sub(pattern, "",column)
    txt2 = re.sub('\[',"",txt1)
    return txt2

def clean_pp_raw(column):
    pattern = r'\[\d*\D*'
    txt1 = re.sub(pattern, "",column)
    return txt1
    
print(df_districts.columns)
df_districts['pct_black/hispanic'] = df_districts['pct_black/hispanic'].apply(clean_pct_hisp)
print (df_districts['pct_black/hispanic'].head(3))
df_districts['pct_free/reduced'] = df_districts['pct_free/reduced'].apply(clean_pct_free)
print (df_districts['pct_free/reduced'].head(3))
df_districts['county_connections_ratio'] = df_districts['county_connections_ratio'].apply(lambda x: clean_cntry_ratio(x))
print (df_districts['county_connections_ratio'].head(3))
df_districts['pp_total_raw'] = df_districts['pp_total_raw'].apply(lambda x: clean_pp_raw(x))
print (df_districts['pp_total_raw'].head(3))


