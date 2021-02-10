# -*- coding: utf-8 -*-
"""
Created on Wed Feb 10 08:38:55 2021
Feature Selection and modelling
@author: Ashish
"""

import pandas as pd, matplotlib.pyplot as plt, seaborn as sns
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import chi2
from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier
# import xgboost
import xgboost as xgb
from sklearn.metrics import explained_variance_score
from imblearn.over_sampling import RandomOverSampler, SMOTE

from sklearn.model_selection import RandomizedSearchCV, GridSearchCV, KFold, cross_val_score
from sklearn.metrics import roc_auc_score
from sklearn.model_selection import StratifiedKFold

from sklearn.metrics import accuracy_score
from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
from sklearn.metrics import classification_report, confusion_matrix  
from sklearn.preprocessing import LabelEncoder
from imblearn.over_sampling import SMOTE
from sklearn import metrics

df = pd.read_csv('../../data/airasia_ancillary_scoring_insurance.csv', encoding ='iso-8859-1')
print(df.shape)
# print(df.columns)
# rearrange the cols such that target var is last
# cols = [col for col in df if col!='INS_FLAG'] + ['INS_FLAG']
# df = df[cols]
# rearrange cols such that categorical are first, followed by continuous and then target var
df = df[['SALESCHANNEL', 'TRIPTYPEDESC','flight_day',
          'ROUTE','geoNetwork_country','BAGGAGE_CATEGORY', 
          'SEAT_CATEGORY', 'FNB_CATEGORY','Id', 'PAXCOUNT',
          'PURCHASELEAD', 'LENGTHOFSTAY', 'flight_hour','flightDuration_hour', 'INS_FLAG']]
print(df.columns)
print(df.shape)

# Encoding categorical data
# creating instance of labelencoder
labelencoder = LabelEncoder()

# Assigning numerical values and storing in new label column
df['ROUTE'] = labelencoder.fit_transform(df['ROUTE'])
df['geoNetwork_country'] = labelencoder.fit_transform(df['geoNetwork_country'])
df['flight_day'] = labelencoder.fit_transform(df['flight_day'])
df['TRIPTYPEDESC'] = labelencoder.fit_transform(df['TRIPTYPEDESC'])
df['SALESCHANNEL'] = labelencoder.fit_transform(df['SALESCHANNEL'])

# print(df.columns)

# Univariate Feature Selection: Statistical tests can be used to select those features that have the strongest relationship with the output variable.
X = df.iloc[:,1:8] # independent categorical cols
y = df.iloc[:,-1] # target col
# print(X)
# print(y)

# https://www.analyticsvidhya.com/blog/2020/10/feature-selection-techniques-in-machine-learning/
#apply SelectKBest class to extract top 7 best features
bestfeatures = SelectKBest(score_func=chi2, k='all')
fit = bestfeatures.fit(X,y)
dfscores = pd.DataFrame(fit.scores_)
dfcolumns = pd.DataFrame(X.columns)
#concat two dataframes for better visualization 
featureScores = pd.concat([dfcolumns,dfscores],axis=1)
featureScores.columns = ['Specs','Score']  #naming the dataframe columns
print(featureScores.nlargest(10,'Score'))  #print  best features

# subset the features with high importance
df_impvars = df[['Id','geoNetwork_country', 'ROUTE','SEAT_CATEGORY',
             'BAGGAGE_CATEGORY','FNB_CATEGORY',
             'flight_day','INS_FLAG']]


# Model building
# prepare train and test data for model training

X = df_impvars.drop(columns=['Id','INS_FLAG'])
y = df['INS_FLAG']

# print("X shape Y shape", X.shape, y.shape)

## train test split size, random seed
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=22, shuffle=True)

# ## Model 1 (baseline) - XGBoost Classifier

xgbc = XGBClassifier( n_estimators= 3000, max_depth=7)
# fit the model to train data set
xgbc.fit(X_train, y_train , eval_metric= 'auc', verbose = 200)
predictions = xgbc.predict(X_test)

## overall model accucary

print("Accuracy:",metrics.accuracy_score(y_test, predictions)) # 82% accuracy on imbalanced dataset
print("Precision:",metrics.precision_score(y_test, predictions))
print("Recall:",metrics.recall_score(y_test, predictions))
print(confusion_matrix(y_test, predictions) )  
print(classification_report(y_test, predictions) )

# Feature importance plot
xgb.plot_importance( xgbc)

# the feature importance plot show the top 5 contributing factor
# route
# flight day
# geo network country
# fnb category
# seat category

# Model 2: XGBOOST with SMOTE oversampling for balancing data

## apply overampling to training dataset
oversample = SMOTE()
# oversample = RandomOverSampler(sampling_strategy='minority')
X_train_os, y_train_os = oversample.fit_resample( X_train, y_train)
## xgbclassifier params
xgbc = XGBClassifier( n_estimators= 3000, max_depth=7)
## fit the model to train data set (using oversampling data)
xgbc.fit(X_train_os, y_train_os , eval_metric= 'auc', verbose = 200)
print(X_train_os.shape, X_train.shape)

predictions = xgbc.predict(X_test)
print("Accuracy:",metrics.accuracy_score(y_test, predictions)) # accuracy decreased to 72% after balancing
print("Precision:",metrics.precision_score(y_test, predictions))
print("Recall:",metrics.recall_score(y_test, predictions))
print(confusion_matrix(y_test, predictions) )
print(classification_report(y_test, predictions) )

# Xgboost cross-validation using random search on best params
# CV model
model = xgb.XGBClassifier()
kfold = KFold(n_splits=10, random_state=7)
results = cross_val_score(model, X, y, cv=kfold)
print("Accuracy: %.2f%% ( std = %.2f%%)" % (results.mean()*100, results.std()*100)) # cross-validation accuracy 83.85%






