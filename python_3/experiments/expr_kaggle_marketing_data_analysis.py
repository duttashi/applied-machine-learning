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
# print(df.columns)
# check for missing values
miss_dat_perc = missing_data_percentage(df)
print(miss_dat_perc)
print(missing_data_plot(df))



