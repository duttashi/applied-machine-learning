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

# print(df_prod_enga.shape, "\n",df_dist.shape)
# print(df_prod_enga.columns, "\n",df_dist.columns)

# Summary stats
# print(df_prod_enga['sector'].value_counts())
# print(df_prod_enga['prim_funct'].value_counts())
# print(df_prod_enga.groupby(['sector', 'prim_funct']).size())

# filter data
# filter data for prek12highEd and LC - Digital Learning Platforms
df_PreK12HigEd = df_prod_enga[ (df_prod_enga['sector']=='preK12_highEd')]
df_Corport = df_prod_enga[ (df_prod_enga['sector']=='Corporate')]
# print(df_PreK12HigEd.shape,"\n",df_Corport.shape)
print(df_Corport.groupby(['sector', 'prim_funct']).size()) # has only 1 level SDO - Data Analytics & reporting
print(df_PreK12HigEd.groupby(['sector', 'prim_funct']).size())

