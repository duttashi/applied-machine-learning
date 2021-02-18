# -*- coding: utf-8 -*-
"""
Created on Tue Feb 16 10:40:40 2021
Data source: https://www.kaggle.com/arashnic/hr-analytics-job-change-of-data-scientists
Objective: Predict the probability of a candidate looking for a new job
@author: Ashish
"""
# required libraries
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from xgboost import XGBClassifier as xgb
from sklearn.impute import SimpleImputer
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.metrics import accuracy_score, precision_score, recall_score
from sklearn.feature_selection import mutual_info_classif
from sklearn.model_selection import  train_test_split

# read the data
df_train = pd.read_csv("../../data/kaggle_hr_analytic_train.csv")

# EDA
print(df_train.shape)
# check for missing values
print("missing value count: ")
print(df_train.isnull().sum())
# print(df_train.dtypes)
# Replace the target variable values with strings
df_train['target']=df_train['target'].map({0:'not_looking',1:'looking'})
# print(df_train['target'].head())

# missing value imputation
imp = SimpleImputer(strategy='most_frequent' )
df_cmplt = pd.DataFrame(imp.fit_transform(df_train)) # impute the missing va;ues then convert to dataframe
df_cmplt.columns = df_train.columns
df_cmplt.index = df_train.index
print(df_cmplt.isnull().sum())
print(df_cmplt.dtypes)
# print("Before encoding categorical vars\n")
# print(df_cmplt.head())

# Encoding the categorical variables
for colname in df_cmplt.select_dtypes("object"):
    df_cmplt[colname], _ = df_cmplt[colname].factorize()
# print("After encoding categorical vars\n")
# print(df_cmplt.head())
# All discrete features should now have integer dtypes (double-check this before using MI!)
# discrete_features = df_cmplt.dtypes == int
# print(discrete_features)

# Feature selection using Mutual Information Selection
# since target variable is categorical in nature, we will use 
# mutual_info_classif from skit-learn feature selection module
X = df_cmplt.copy()
y = X.pop("target")
mi_scores = mutual_info_classif(X, y, discrete_features=True, random_state=19)
mi_scores = pd.Series(mi_scores, name="MI Scores", index=X.columns)
mi_scores = mi_scores.sort_values(ascending=False)
print("### Feature selection using mutual information scores")
print(mi_scores)  # show a few features with their MI scores
# the variables gender, major_discipline are independent to target variable
# the variables city_development_index, city, company_size, experience are weakly related to the target variable
df_train_imp_feats = df_cmplt[['city','city_development_index','experience',
                         'company_size','enrolled_university','target']]
print(df_train_imp_feats.shape)

# plotting the relevant features

# define a custom plotting function
def plot_utility_scores(scores):
    y = scores.sort_values(ascending=True)
    width = np.arange(len(y))
    ticks = list(y.index)
    plt.barh(width, y)
    plt.yticks(width, ticks)
    plt.title("Mutual Information Scores")
# plot
plt.figure(dpi=100, figsize=(8, 5))
plot_utility_scores(mi_scores)

sns.barplot(x="target", y="experience", data=df_cmplt)
# split the training encoded data into train, test, validation set

# Model building

# 1. Split the data into train and test
X = df_train_imp_feats.copy()
y = X.pop("target")
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.3)

# Model 1 (baseline) - XGBoost Classifier

xgr = xgb( n_estimators= 3000, max_depth=7)
# fit the model to train data set
xgr.fit(X_train, y_train , eval_metric= 'auc', verbose = 200)
predictions = xgr.predict(X_test)
# print(predictions)

# overall model accucary
predictions = xgr.predict(X_test)
print("Accuracy:", accuracy_score(y_test, predictions)) # 73%
# 83% accuracy on imbalanced dataset
print("Precision:", precision_score(y_test, predictions)) # 81%
print("Recall:", recall_score(y_test, predictions)) # 85%
print(confusion_matrix(y_test, predictions))
print(classification_report(y_test, predictions))

