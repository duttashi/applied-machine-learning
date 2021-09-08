# -*- coding: utf-8 -*-
"""
data source: https://www.kaggle.com/c/learnplatform-covid19-impact-on-digital-learning/data
reference: https://www.kaggle.com/ruchi798/covid-19-impact-on-digital-learning-eda-w-b#Reading-data-files-%F0%9F%91%93
"""
import pandas as pd
import glob
import numpy as np
# import glob
# read data
df_products = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/products_info.csv")
print(df_products.shape)
df_districts = pd.read_csv("../../data/learnplatform-covid19-impact-on-digital-learning/districts_info.csv")
print(df_districts.shape)

#reading multiple files from a folder into a list
path = '../../data/learnplatform-covid19-impact-on-digital-learning/engagement_data' 
all_files = glob.glob(path + "/*.csv")

li = []

for filename in all_files:
    df = pd.read_csv(filename, index_col=None, header=0)
    district_id = filename.split("/")[4].split(".")[0]
    df["district_id"] = district_id
    li.append(df)
    
df_engagement = pd.concat(li)
df_engagement = df_engagement.reset_index(drop=True)
print(df_engagement.shape)

# write to disk
path = '../../data/learnplatform-covid19-impact-on-digital-learning/'
df_engagement.to_csv(path+'engagement_combine.csv')
print(df_engagement.close())

# read the engagement data from disc
path = '../../data/learnplatform-covid19-impact-on-digital-learning/'
df_engagement = pd.read_csv(path+'engagement_combine.csv')
print(df_engagement.shape)
print(df_engagement.dtypes)
def get_df_name(df):
    name =[x for x in globals() if globals()[x] is df][0]
    return name

def find_null_columns(dataframe):
    
    list_of_nullcolumns =[]
    # print dataframe name to improve result readability
    df_name = get_df_name(dataframe)
    print("\nFor dataframe name ", df_name," summary as follows;")
    
    for column in dataframe.columns:
        # print(column)
        total= dataframe[column].isna().sum()
        try:
            if total !=0:
                print('Total Na values is {0} for column {1}' .format(total, column))
                list_of_nullcolumns.append(column)
        except:
            print(column,"-----",total)
    
    # print('\n')
    
    return list_of_nullcolumns

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

missdata = find_null_columns(df_engagement)
print("missing engagement data", missdata)
missdata = find_null_columns(df_districts)
print("missing districts data", missdata)
missdata = find_null_columns(df_products)
print("missing products data", missdata)

# Impute missing data
df1 = replace_blanks(df_districts)
df_clean = fill_missing(df1)
# write clean data to disk
df_clean.to_csv(path+'clean_district.csv', sep=",")
print(df_clean.isnull().sum())

df1 = replace_blanks(df_products)
df_clean = fill_missing(df1)
# write clean data to disk
df_clean.to_csv(path+'clean_products.csv', sep=",")
print(df_clean.isnull().sum())

df1 = replace_blanks(df_engagement)
df_clean = fill_missing(df1)
# write clean data to disk
df_clean.to_csv(path+'clean_engage.csv', sep=",")
print(df_clean.isnull().sum())


