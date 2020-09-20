# -*- coding: utf-8 -*-
"""
Created on Wed Apr 22 13:55:51 2020
Aim: To understand the process of feature engineering and how it can help to build better predictive models
Objective:To create features from existing variables in a given dataset
Dataset: https://www.kaggle.com/c/house-prices-advanced-regression-techniques
Required libraries: matplotlib, numpy, pandas, scipy
Reference: https://www.kaggle.com/serigne/stacked-regressions-top-4-on-leaderboard
@author: Ashish
"""
import pandas as pd, numpy as np, matplotlib.pyplot as plt, seaborn as sns
from scipy import stats
from scipy.stats import norm, skew #for some statistics


color = sns.color_palette()
sns.set_style('darkgrid')
import warnings
def ignore_warn():
    pass
warnings.warn = ignore_warn #ignore annoying warning (from sklearn and seaborn)

# Load the data
train_data = pd.read_csv("../data/kaggle_houseprice_train.csv")
test_data = pd.read_csv("../data/kaggle_houseprice_test.csv")
print("The train data size before dropping the id feature is: ", train_data.shape)
print("The test data size before dropping the id feature is: ", test_data.shape)

# Save the Id column
train_data_ID = train_data["Id"]
test_data_ID = test_data["Id"]

#Now drop the  'Id' colum since it's unnecessary for  the prediction process.
train_data.drop("Id", axis=1, inplace=True)
print("The train data size after dropping the id feature is: ", train_data.shape)
test_data.drop("Id", axis=1, inplace=True)
print("The train data size after dropping the id feature is: ", test_data.shape)

# Data Processing
## Outlier visualization
FIG,AX = plt.subplots()
AX.scatter(x=train_data['GrLivArea'], y=train_data['SalePrice'])
plt.ylabel('SalePrice', fontsize=13)
plt.xlabel('GrLivArea', fontsize=13)
plt.show()

#Deleting outliers
train_data=train_data.drop(train_data[(train_data['GrLivArea']>4000) & (train_data['SalePrice']<300000)].index)

#Check the graphic again
FIG,AX = plt.subplots()
AX.scatter(x=train_data['GrLivArea'], y=train_data['SalePrice'])
plt.ylabel('SalePrice', fontsize=13)
plt.xlabel('GrLivArea', fontsize=13)
plt.show()

# Target Variable
# SalePrice is the variable we need to predict. So let's do some analysis on this variable first.
sns.distplot(train_data['SalePrice'], fit=norm)

# Get the fitted parameters used by the function
(mu, sigma) = norm.fit(train_data['SalePrice'])
print('\n mu = {:.2f} and sigma = {:.2f}\n'.format(mu, sigma))

#Now plot the distribution
plt.legend(['Normal dist. ($mu=$ {:.2f} and $sigma=$ {:.2f} )'.format(mu, sigma)],loc='best')
plt.ylabel('Frequency')
plt.title('SalePrice distribution')

#Get also the QQ-plot
FIG = plt.figure()
res = stats.probplot(train_data['SalePrice'], plot=plt)
plt.show()

# The target variable is right skewed. As (linear) models love normally distributed data , 
# we need to transform this variable and make it more normally distributed.
# Log-transformation of the target variable
#We use the numpy fuction log1p which  applies log(1+x) to all elements of the column
train_data["SalePrice"]=np.log1p(train_data["SalePrice"])

#Check the new distribution 
sns.distplot(train_data['SalePrice'],fit=norm)
# Get the fitted parameters used by the function
(mu,sigma)=norm.fit(train_data['SalePrice'])
print( '\n mu = {:.2f} and sigma = {:.2f}\n'.format(mu, sigma))

#Now plot the distribution
plt.legend(['Normal dist. ($mu=$ {:.2f} and $sigma=$ {:.2f} )'.format(mu, sigma)],loc='best')
plt.ylabel('Frequency')
plt.title('SalePrice distribution')

#Get also the QQ-plot
fig=plt.figure()
res=stats.probplot(train_data['SalePrice'], plot=plt)
plt.show()

# Features engineering on training data
train_data_na=(train_data.isnull().sum()/len(train_data))*100
train_data_na=train_data_na.drop(train_data_na[train_data_na == 0].index).sort_values(ascending=False)[:30]
train_data_missing=pd.DataFrame({'Missing Ratio': train_data_na})
print(train_data_missing)

FIG,AX=plt.subplots(figsize=(15, 12))
plt.xticks(rotation='90')
sns.barplot(x=train_data_na.index, y=train_data_na)
plt.xlabel('Features', fontsize=15)
plt.ylabel('Percent of missing values', fontsize=15)
plt.title('Percent missing data by feature', fontsize=15)

# Data correlation
# plot a correlation map to see how the features are related to variable SalePrice
corr_mat=train_data.corr()
plt.subplots(figsize=(12,9))
sns.heatmap(corr_mat, vmax=0.9, square=True)

# Missing data imputation
train_data["PoolQC"]=train_data["PoolQC"].fillna("None")
train_data['MiscFeature']=train_data["MiscFeature"].fillna("None")
train_data["Alley"]=train_data["Alley"].fillna("None")
train_data["Fence"]=train_data["Fence"].fillna("None")
train_data["FireplaceQu"]=train_data["FireplaceQu"].fillna("None")
train_data["LotFrontage"]=train_data["LotFrontage"].fillna("None")

train_data_na=(train_data.isnull().sum()/len(train_data))*100
train_data_na=train_data_na.drop(train_data_na[train_data_na == 0].index).sort_values(ascending=False)[:30]
train_data_missing=pd.DataFrame({'Missing Ratio': train_data_na})
print("\n",train_data_missing)


