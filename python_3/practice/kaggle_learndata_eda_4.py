# -*- coding: utf-8 -*-
"""
Created on Sun Sep 12 14:36:03 2021
data source: https://www.kaggle.com/c/learnplatform-covid19-impact-on-digital-learning/data
@author: Ashish
"""
import pandas as pd
import numpy as np

# read districts, engage, products data
path = '../../data/learnplatform-covid19-impact-on-digital-learning/'

df_prod = pd.read_csv(path+"products_info.csv")
df_dist = pd.read_csv(path+"districts_info.csv")
df_enga = pd.read_csv(path+'engagement_combine.csv')

print(df_prod.shape, df_dist.shape)

# EDA

# lowercase column names
df_prod.columns = [x.lower() for x in df_prod.columns]
df_dist.columns = [x.lower() for x in df_dist.columns]
# df_enga.columns = [x.lower() for x in df_enga.columns]

# rename cols for product
df_prod = df_prod.rename(columns={'lp id':'lp_id',
                            'product name':'prod_name',
                            'provider/company name':'company_name',
                            'sector(s)':'sector',
                            'primary essential function':'prim_funct'}
                   )

print(df_prod['sector'].value_counts())

# replace factor levels to avoid ambiguity
df_prod['sector']= df_prod['sector'].replace({'PreK-12; Higher Ed; Corporate':'preK12_corpr',
                                              'PreK-12; Higher Ed':'preK12_highEd',
                                              'PreK-12':'preK12_highEd',
                                              'Higher Ed; Corporate':'Corporate'}
                                             )
# Merge engage with products data on lp id
df_prod_enga = df_prod.merge(df_enga, on = 'lp_id',how = 'inner')
print(df_enga.isnull().sum())

# replace blank with nan
def replace_blanks(dataframe):
    dataframe = dataframe.replace(r'^\s*$', np.nan, regex=True)
    return dataframe

def fill_missing(dataframe):
    df_imputed = replace_blanks(dataframe)
    for col in df_imputed.columns:
        if(df_imputed[col].dtype == 'object'):
            df_imputed[col] = df_imputed[col].fillna(df_imputed[col].mode()[0])
        elif (df_imputed[col].dtype == 'int64'):
            # df_imputed[col] = df_imputed[col].astype(str)
            df_imputed[col] = df_imputed[col].fillna(df_imputed[col].median())
        elif (df_imputed[col].dtype == 'float64'):
            # df_imputed[col] = df_imputed[col].astype(int)
            df_imputed[col] = df_imputed[col].fillna(df_imputed[col].median())
        else:
            continue
    # return imputed dataframe
    return df_imputed

df_prod_enga = replace_blanks(df_prod_enga)
df_prod_enga_imputd = fill_missing(df_prod_enga)
print(df_prod_enga_imputd.isnull().sum())

# write clean data to disk
df_prod_enga_imputd.to_csv(path+'df_prod_enga_clean.csv', sep=",", index=False)






