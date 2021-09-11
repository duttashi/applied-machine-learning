# -*- coding: utf-8 -*-
"""
Created on Sat Sep 11 14:18:51 2021
Objective: Read raw data files and clean it
@author: Ashish
"""

import pandas as pd
import re

df_products = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_products.csv")
df_districts = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_district.csv")
# df_engage = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_engage.csv")

# lowercase column names
df_products.columns = [x.lower() for x in df_products.columns]
df_districts.columns = [x.lower() for x in df_districts.columns]

# define custom functions for data cleaning

# Products data file
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
df_districts['pct_free/reduced'] = df_districts['pct_free/reduced'].apply(clean_pct_free)
df_districts['county_connections_ratio'] = df_districts['county_connections_ratio'].apply(lambda x: clean_cntry_ratio(x))
df_districts['pp_total_raw'] = df_districts['pp_total_raw'].apply(lambda x: clean_pp_raw(x))

print (df_districts['pct_black/hispanic'].head(3))
print (df_districts['pct_free/reduced'].head(3))
print (df_districts['county_connections_ratio'].head(3))
print (df_districts['pp_total_raw'].head(3))

# Districts file
# print("\n##### Districts#####")
# print(df_products.columns)
# # 1. Extract domain name from URL
# def domain_name(urlColumn):
#     from urllib.parse import urlparse
#     tmp = urlparse(urlColumn).netloc
#     domain = '.'.join(tmp.split('.')[1:])
#     return domain

# df_products['domain'] = df_products['url'].apply(lambda x: domain_name('url'))
# print (df_products['domain'].head(3))
