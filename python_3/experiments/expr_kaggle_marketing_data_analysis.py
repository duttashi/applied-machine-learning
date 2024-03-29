# -*- coding: utf-8 -*-
"""
Created on Sun Dec 20 15:05:25 2020
Data source: https://www.kaggle.com/jackdaoud/marketing-data 
Task: 
    1. What factors are significantly related to the number of store purchases?
    2. Your supervisor insists that people who buy gold are more conservative. Therefore, people who spent an above average amount on gold in the last 2 years would have more in store purchases. Justify or refute this statement using an appropriate statistical test
    3. Fish has Omega 3 fatty acids which are good for the brain. Accordingly, do "Married PhD candidates" have a significant relation with amount spent on fish? What other factors are significantly related to amount spent on fish? (Hint: use your knowledge of interaction variables/effects)
    4. Is there a significant relationship between geographical regional and success of a campaign?
    
@author: Ashish
"""
import pandas as pd
import matplotlib.pyplot as plt
# load the data in-memory
df = pd.read_csv("../../data/kaggle_marketing_data.csv")

# Exploratory data analysis

# custom functions
def get_miss_cols(data):
    miss_cols = data.columns[data.isnull().any()]
    return miss_cols

def missing_data_percentage(data):
    
    data_na = (data.isnull().sum() / len(data)) * 100
    
    data_na = data_na.drop(data_na[data_na == 0].index).sort_values(ascending=False)[:30]
    
    return data_na

def missing_data_plot(data_na):
    x = data_na
    fig = plt.figure(figsize=(8, 6))
    plt.plot(x)
    # use plt.show() when the function is not returning a value
    # plt.show()
    # use return
    return fig


# number of cols and rows
print(df.shape) # 2240 rows, 28 cols
print(df.columns)
print(df.dtypes) # print column data types

# convert column data types
df['Year_Birth'] = pd.to_datetime(df['Year_Birth'])
df['Dt_Customer'] = pd.to_datetime(df['Dt_Customer'])

# collect multiple olumns in a list and change their data type
change_cols_dtype = ['Kidhome','Teenhome','AcceptedCmp3',
                     'AcceptedCmp4','AcceptedCmp5','AcceptedCmp1',
                     'AcceptedCmp1','AcceptedCmp2',
                     'Response','Complain']
df[change_cols_dtype] = df[change_cols_dtype].astype(str)

# remove dollar & comma sign from Income variable and change dtype to float
df['Income'] = df['Income'].str.replace(',', '').str.replace('$', '').astype(float)

print(df.dtypes) # print column data types

# check for missing values
miss_dat_perc = missing_data_percentage(df)
print(miss_dat_perc)
miss_data = get_miss_cols(df)
print(miss_data)

# Feature Engineering
# Create new columns
df['day'] = df['Dt_Customer'].dt.day
df['month'] = df['Dt_Customer'].dt.month
df['year'] = df['Dt_Customer'].dt.year

print(df.head(5))


