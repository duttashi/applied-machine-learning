# -*- coding: utf-8 -*-
"""
Created on Thu Aug 19 15:46:00 2021

@author: Ashoo
"""

import pandas as pd
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix, classification_report
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score

# load the data
df = pd.read_csv("../../data/uciml_winequality_red.csv")
# EDA
print(df.head)
print(df.info)
print(df.columns)

# check for missing

# check for unique values in response variable
print(df['quality'].unique())

bins = (2, 6.5, 8)
group_names = ['bad', 'good']
df['quality'] = pd.cut(df['quality'], bins = bins, labels = group_names)
print(df['quality'].head)

#Now lets assign a labels to our quality variable
label_quality = LabelEncoder()
print(df['quality'].value_counts())
# imbalanced data classification

#Now seperate the dataset as response variable and feature variabes
X = df.drop('quality', axis = 1)
y = df['quality']
#Train and Test splitting of data 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = 42)
#Applying Standard scaling to get optimized result
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.fit_transform(X_test)

## Imbalanced data classification
rfc = RandomForestClassifier(n_estimators=200)
rfc.fit(X_train, y_train)
pred_rfc = rfc.predict(X_test)
#Let's see how our model performed
print(classification_report(y_test, pred_rfc))

