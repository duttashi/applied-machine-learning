# -*- coding: utf-8 -*-
"""
Created on Sun Sep 20 11:03:26 2020

@author: Ashish

Improvement options: 
    1. Write a function to find all categorical features and numeric features in a given dataframe. 
     return separate dataframe having categoriacl and numerical features
    2. Write a function that accepts a dataframe and returns the encoded features in numeric format
"""
# pip install Boruta
from boruta import BorutaPy
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
# for label encoding
from sklearn import preprocessing
# print working directory
import os
print(os.getcwd())

# read the data
df = pd.read_csv("../../data/adult.csv")

# EDA
print(df.head)
print(df.shape)
print(df.columns)
print(df.info)
print(df.describe)

# Label Encoding of the categorical features into numeric

label_encoder = preprocessing.LabelEncoder()
# encode all categorical variables
df['workclass']= label_encoder.fit_transform(df['workclass'])
df['education']= label_encoder.fit_transform(df['education'])
df['marital.status']= label_encoder.fit_transform(df['marital.status']) 
df['occupation']= label_encoder.fit_transform(df['occupation']) 
df['relationship']= label_encoder.fit_transform(df['relationship'])
df['race']= label_encoder.fit_transform(df['race'])
df['sex']= label_encoder.fit_transform(df['sex'])
df['native.country']= label_encoder.fit_transform(df['native.country'])
df['income']= label_encoder.fit_transform(df['income'])

# Feature Selection
df_X = df.iloc[:, 1:]
df_y = df.iloc[:, 0]
clf = RandomForestClassifier(n_estimators=50, n_jobs=-1, max_depth=5)
trans = BorutaPy(clf, random_state=17, verbose=2)
sel = trans.fit_transform(df_X.values, df_y.values)
boruta_selector = sel
# number of selected features
print ('\n Number of selected features:')
print (boruta_selector)



