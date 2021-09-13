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
df_engage = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/clean_engage.csv")

# lowercase column names
df_products.columns = [x.lower() for x in df_products.columns]
df_districts.columns = [x.lower() for x in df_districts.columns]
df_engage.columns = [x.lower() for x in df_engage.columns]

# rename cols for product
df_products = df_products.rename(columns={'lp id':'lp_id',
                            'product name':'prod_name',
                            'provider/company name':'company_name',
                            'sector(s)':'sector',
                            'primary essential function':'prim_funct'}
                   )

# show dataframe columns
print("products columns\n", df_products.columns,
      "\ndistrict columns\n", df_districts.columns,
      "\nengage columns\n",df_engage.columns)

# define custom functions for data cleaning

# Products data file
def district_clean_pct_hisp(column):
    pattern = r'\[\d\,[^\d]'
    txt1 = re.sub(pattern, "",column)
    txt2 = re.sub('\[',"",txt1)
    return txt2

def district_clean_pct_free(column):
    pattern = r'\[\d\D\d\D[^\d]'
    txt1 = re.sub(pattern, "",column)
    txt2 = re.sub('\[',"",txt1)
    return txt2

def district_clean_cntry_ratio(column):
    pattern = r'\[\d\D\d*\D*'
    txt1 = re.sub(pattern, "",column)
    txt2 = re.sub('\[',"",txt1)
    return txt2

def district_clean_pp_raw(column):
    pattern = r'\[\d*\D*'
    txt1 = re.sub(pattern, "",column)
    return txt1

def district_clean_state(dataframe, column):
    us_state_abbrev = {
    'Alabama': 'AL',
    'Alaska': 'AK',
    'American Samoa': 'AS',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'District Of Columbia': 'DC',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Guam': 'GU',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Northern Mariana Islands':'MP',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Pennsylvania': 'PA',
    'Puerto Rico': 'PR',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virgin Islands': 'VI',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY'
    }
    
    dataframe['state_abbrev'] = dataframe[column].replace(us_state_abbrev)
    dataframe = dataframe['state_abbrev'].value_counts().to_frame().reset_index(drop=False)
    dataframe.columns = ['state_abbrev','num_districts']
    
    return dataframe

# print(df_districts.columns)
df_districts['pct_black/hispanic'] = df_districts['pct_black/hispanic'].apply(district_clean_pct_hisp)
df_districts['pct_free/reduced'] = df_districts['pct_free/reduced'].apply(district_clean_pct_free)
df_districts['county_connections_ratio'] = df_districts['county_connections_ratio'].apply(lambda x: district_clean_cntry_ratio(x))
df_districts['pp_total_raw'] = df_districts['pp_total_raw'].apply(lambda x: district_clean_pp_raw(x))
df_districts['state'] = df_districts['state'].apply(lambda x: district_clean_state(df_districts,"state"))
# print (df_districts['pct_black/hispanic'].head(3))
# print (df_districts['pct_free/reduced'].head(3))
# print (df_districts['county_connections_ratio'].head(3))
# print (df_districts['pp_total_raw'].head(3))
print("\n## Districts\n",df_districts.columns)

# write to disk
df_districts.to_csv("../../data/learnplatform-covid19-impact-on-digital-learning/district_clean.csv", sep=",")


# Only consider districts and products with full engagement data
df_districts_new = df_districts[df_districts.district_id.isin(df_engage.district_id.unique())].reset_index(drop=True)
df_products_new = df_products[df_products['lp_id'].isin(df_engage.lp_id.unique())].reset_index(drop=True)

print("Original data shape\n")
print(df_products.shape, df_districts.shape)
print("\nNew data shape")
print(df_products_new.shape, df_districts_new.shape)

### Merge engage with products data on lp id
df_prod_engage = df_products.merge(df_engage, on = 'lp_id',
                                       how = 'inner')
print("\nEngage data shape: ", df_engage.shape)
print("\nProducts data shape: ", df_products.shape)
print("\nProduct- Enagage matches", df_prod_engage.shape)
print("\nProduct- Enagage variables", df_prod_engage.columns)

# write to disk
df_prod_engage.to_csv("../../data/learnplatform-covid19-impact-on-digital-learning/prod_engage_join_clean.csv", sep=",")
# merge product-engage data with districts data on district_id

# df_prod_engage_dist = df_prod_engage.merge(df_districts, on = 'district_id',
#                                            how='inner')
# print("\nProduct Engage District data shape & variables\n",
#       df_prod_engage_dist.shape, df_prod_engage_dist.columns)

print(df_prod_engage.dtypes)

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
