# -*- coding: utf-8 -*-
"""
Created on Sun Sep 12 11:06:56 2021
EDA Final
@author: Ashish
"""

import pandas as pd
import glob
import numpy as np

path = '../../data/learnplatform-covid19-impact-on-digital-learning/'

# read the products engage clean & distriicts data files
df_dist = pd.read_csv(path+"districts_info.csv")
df_prod = pd.read_csv(path+"products_info.csv")
# df_engage = pd.read_csv(path+'engagement_combine.csv')
#reading multiple files from a folder into a list
all_files = glob.glob(path + "/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0)
    # district_id = filename.split("/")[4].split(".")[0]
    # df["district_id"] = district_id
    li.append(df)
    
df_engage = pd.concat(li, axis=0, ignore_index=True)

# lowercase column names
df_prod.columns = [x.lower() for x in df_prod.columns]
df_dist.columns = [x.lower() for x in df_dist.columns]
df_engage.columns = [x.lower() for x in df_engage.columns]

# rename cols for product
df_prod = df_prod.rename(columns={'lp id':'lp_id',
                            'product name':'prod_name',
                            'provider/company name':'company_name',
                            'sector(s)':'sector',
                            'primary essential function':'prim_funct'}
                   )
# replace factor levels to avoid ambiguity
df_prod['sector']= df_prod['sector'].replace({'PreK-12; Higher Ed; Corporate':'preK12_corpr',
                                              'PreK-12; Higher Ed':'preK12_highEd',
                                              'PreK-12':'preK12_highEd',
                                              'Higher Ed; Corporate':'Corporate'}
                                             )

# join districst, products, engagement files
# Merge engage with products data on lp id
df1 = df_prod.merge(df_engage, on = 'lp_id',how = 'inner')
df_combine = pd.concat([df_dist, df1], axis=1)
print("\n combine files data shape: ", df_combine.shape)

# filter data for prek12highEd and LC - Digital Learning Platforms
df_PreK12HigEd = df_combine[ (df_combine['sector']=='preK12_highEd')]
print("\n prek12 to high edu data shape: ",df_PreK12HigEd.shape)

# TO DO Tomorrow
# Filter out all missing data
# Visualise

# Impute missing
# replace blank with nan
# def replace_blanks(dataframe):
#     dataframe = dataframe.replace(r'^\s*$', np.nan, regex=True)
#     return dataframe

# def fill_missing(dataframe):
#     df_imputed = replace_blanks(dataframe)
#     for col in df_imputed.columns:
#         if(df_imputed[col].dtype == 'object'):
#             df_imputed[col] = df_imputed[col].fillna(df_imputed[col].mode()[0])
#         elif (df_imputed[col].dtype == 'int64'):
#             # df_imputed[col] = df_imputed[col].astype(str)
#             df_imputed[col] = df_imputed[col].fillna(df_imputed[col].median())
#         elif (df_imputed[col].dtype == 'float64'):
#             # df_imputed[col] = df_imputed[col].astype(int)
#             df_imputed[col] = df_imputed[col].fillna(df_imputed[col].median())
#         else:
#             continue
#     # return imputed dataframe
#     return df_imputed


# df_PreK12HigEd_cl = replace_blanks(df_PreK12HigEd)
# df_PreK12HigEd_clean = fill_missing(df_PreK12HigEd_cl)

# # write prek12_highEd sector to disk for further analysis
# df_PreK12HigEd_clean.to_csv(path+'df_PreK12HigEd.csv', sep=",", index=False)




