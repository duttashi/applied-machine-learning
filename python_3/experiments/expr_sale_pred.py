# -*- coding: utf-8 -*-
"""
Created on Fri Mar 19 13:04:47 2021
Data source: https://www.kaggle.com/sazid28/advertising.csv
@author: Ashish
"""

# load requied libraries
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import style
import seaborn as sns
import statsmodels.api as sm
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from numpy import reshape

style.use("ggplot")
# load data
df = pd.read_csv("../../data/kaggle_advertising.csv")
print(df.head(5))

# check data length and duplicates
print(len(df))
print(df.duplicated().any()) # no duplicates
print(df.isnull().sum()) # no null values
#Basic statistical report
df.describe().style.format("{:.2f}")
# lowercase all column names
df.columns = df.columns.str.lower()

sns.pairplot(df, x_vars = ['tv','radio','newspaper'], 
             y_vars='sales',height=7, kind='reg')
X = df[["tv","radio","newspaper"]] 
y = df.sales

plt.figure(figsize=(10,5))
sns.heatmap(df.corr(),
            annot=True,
            linewidths=.5,
            center=0,
            cbar=False,
            cmap='RdBu_r')
plt.show()
# build OLS regression model
model = sm.OLS(y, X).fit()
print(model.summary())

# From the OLS model, I found the p-value for radio and newspaper. both are less than 0.05, so we could take both for create a model. since the radio and newspaper suffered with multi collinearity, I choose newspaper to drop because it has a higher p-value than the radio.
X = df[['tv','radio']]
y = df.sales
# print(y)

# Machine Learning
# split the data into train test split
xtrain, xtest, ytrain, ytest = train_test_split(X, y, train_size=0.65,test_size=0.35, random_state=101)
# # print("Data Shape\n")
# print ("X_train: ", xtrain.shape)
# print ("y_train : ", ytrain.shape)
# print("X_test: ", xtest.shape)
# print ("y_test: ", ytest.shape)

model = LinearRegression()
model.fit(xtrain,ytrain)
# make prediction on test set
# print(y_test.shape)
ypred = model.predict(xtest)
result = pd.DataFrame()
result['xtest - tv'] = xtest['tv'].copy()
result['xtest - radio'] = xtest['radio'].copy()
result['ytest'] = ytest.copy()
result['ypred'] = ypred.copy()
print(result.head())



