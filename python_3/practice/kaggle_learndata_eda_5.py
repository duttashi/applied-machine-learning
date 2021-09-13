# -*- coding: utf-8 -*-
"""
Created on Sun Sep 12 15:45:43 2021

@author: Ashish
"""
import pandas as pd


# read districts, engage, products data
path = '../../data/learnplatform-covid19-impact-on-digital-learning/'

df_dist = pd.read_csv(path+"districts_info.csv")
df_prod_enga = pd.read_csv(path+'df_prod_enga_clean.csv')

df_combine = pd.concat([df_dist, df_prod_enga], axis=1)
print(df_combine.shape,"\n", df_combine.columns)


# print(df_prod_enga.shape, "\n",df_dist.shape)
# print(df_prod_enga.columns, "\n",df_dist.columns)

# Summary stats
# print(df_prod_enga['sector'].value_counts())
# print(df_prod_enga['prim_funct'].value_counts())
# print(df_prod_enga.groupby(['sector', 'prim_funct']).size())

# Add a percentage column for product usage 
prod_usage = df_combine.groupby('sector')['prod_name'].count().reset_index()
prod_usage['perct'] = 100 * prod_usage['prod_name'] / prod_usage['prod_name'].sum()
print(prod_usage.head(3))

# filter data
# filter data for prek12highEd and LC - Digital Learning Platforms
df_PreK12HigEd = df_combine[ (df_combine['sector']=='preK12_highEd')]
# df_Corport = df_prod_enga[ (df_prod_enga['sector']=='Corporate')]
print(df_PreK12HigEd.shape)
# print(df_Corport.groupby(['sector', 'prim_funct']).size()) # has only 1 level SDO - Data Analytics & reporting
# print(df_PreK12HigEd.groupby(['sector', 'prim_funct']).size())

# write prek12_highEd sector to disk for further analysis
df_PreK12HigEd.to_csv(path+'df_PreK12HigEd.csv', sep=",", index=False)

