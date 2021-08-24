# -*- coding: utf-8 -*-
"""
Created on Wed Aug  4 13:32:51 2021
https://www.kaggle.com/yashvi/vehicle-insurance-eda-and-boosting-models
@author: Ashish
"""

import pandas as pd
import seaborn as sns
# load data
df_tr = pd.read_csv("../../data/kaggle_health_crossell_train.csv")
df_te = pd.read_csv("../../data/kaggle_health_crossell_test.csv")
print("\n train shape: ", df_tr.shape)
print("\n test shape: ", df_te.shape)
print("\n train data types\n", df_tr.dtypes)
print("\n train missing vals: ", df_tr.isnull().sum())
print("\n test missing vals: ", df_te.isnull().sum())

# segregate continuous & categorgical cols
numerical_cols = [cname for cname in df_tr.columns if 
                df_tr[cname].dtype in ['int64', 'float64']]

categorical_cols = [cname for cname in df_tr.columns if
                    df_tr[cname].nunique() < 50 and 
                    df_tr[cname].dtype in ['object', 'bool']]
print("\n numerical cols: ", df_tr[numerical_cols].columns)
print("\n categorical cols: ", df_tr[categorical_cols].columns)

print("\n", df_tr[numerical_cols].describe)
print("\n", df_tr[categorical_cols].describe)

# lowercase all column names
df_tr.columns = [x.lower() for x in df_tr.columns]
print("\n col names\n", df_tr.columns)

# Data visualization
# 1. plot response variable
sns.countplot(x=df_tr.response)
# 2. Distributions
sns.displot(x=df_tr.age)
# 3. relations
# Age Vs Annual premium
sns.scatterplot(x = df_tr['age'], y= df_tr['annual_premium'])
# Gender vs annual premium
sns.scatterplot(x = df_tr['gender'], y= df_tr['annual_premium'])
# previously_insured vs annual premium
sns.scatterplot(x = df_tr['previously_insured'], y= df_tr['annual_premium'])
# Data preprocessing
## 1. 

