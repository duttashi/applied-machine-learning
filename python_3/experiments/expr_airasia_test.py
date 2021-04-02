# -*- coding: utf-8 -*-
"""
Data analysis for Air Asia Lead data scientist role
Objective: to predict whether a customer will buy insurance from airline or not 
Script author: Ashish Dutt
Script create date: 11/2/2020
Script last modified date: 14/2/2020
Email: ashishdutt@yahoo.com.my
"""

import pandas as pd
import seaborn as sns

from sklearn.model_selection import train_test_split
from xgboost import XGBClassifier as xgb
from sklearn.model_selection import (
    RandomizedSearchCV,
    GridSearchCV,
    KFold,
    cross_val_score,
)
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.preprocessing import LabelEncoder
from imblearn.over_sampling import SMOTE
import matplotlib.pyplot as plt

df = pd.read_csv(
    "../../data/airasia_ancillary_scoring_insurance.csv", encoding="iso-8859-1"
)
print(df.shape)
print(df.columns)

## check target variable class distribution
print(df["INS_FLAG"].value_counts())  # imbalanced data
## detect null & missing value
print(df.isnull().sum())

## correlation


# calculate the correlation matrix
corr = df.corr()

print(corr)

# plot the heatmap
sns.heatmap(corr, xticklabels=corr.columns, yticklabels=corr.columns)

# Encoding categorical data
# creating instance of labelencoder
labelencoder = LabelEncoder()

# Assigning numerical values and storing in new label column
df["ROUTE_code"] = labelencoder.fit_transform(df["ROUTE"])
df["geoNetwork_country_code"] = labelencoder.fit_transform(df["geoNetwork_country"])
df["flight_day_code"] = labelencoder.fit_transform(df["flight_day"])
df["TRIPTYPEDESC_code"] = labelencoder.fit_transform(df["TRIPTYPEDESC"])
df["SALESCHANNEL_code"] = labelencoder.fit_transform(df["SALESCHANNEL"])

print(df.head(5))

# Model building
# prepare train and test data for model training

X = df.drop(
    columns=[
        "INS_FLAG",
        "ROUTE",
        "geoNetwork_country",
        "flight_day",
        "TRIPTYPEDESC",
        "SALESCHANNEL",
    ]
)
y = df["INS_FLAG"]

## train test split size, random seed
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=22
)

## Model 1 (baseline) - XGBoost Classifier

xgr = xgb(n_estimators=3000, max_depth=7)
# fit the model to train data set
xgr.fit(X_train, y_train, eval_metric="auc", verbose=200)
predictions = xgr.predict(X_test)
# print(predictions)

## overall model accucary
from sklearn import metrics

predictions = xgr.predict(X_test)

print(
    "Accuracy:", metrics.accuracy_score(y_test, predictions)
)  # 83% accuracy on imbalanced dataset
print("Precision:", metrics.precision_score(y_test, predictions))
print("Recall:", metrics.recall_score(y_test, predictions))

print(confusion_matrix(y_test, predictions))
print(classification_report(y_test, predictions))

# Feature importance plot
# xgb.plot_importance( xgr)

# the feature importance plot show the top 5 contributing factor
# purchase lead amount
# route
# lenght of stay
# flight hour
# flight day code
# the least contributing factor
# trip type (round trip, one-way , cycle)
# sales channel (mobile, desktop)
# baggage category

# Model 2: XGBOOST with SMOTE oversampling for balancing data

## apply overampling to training dataset
oversample = SMOTE()
# oversample = RandomOverSampler(sampling_strategy='minority')
X_train_os, y_train_os = oversample.fit_resample(X_train, y_train)
## xgbclassifier params
xgr = xgb(n_estimators=3000, max_depth=7)
## fit the model to train data set (using oversampling data)
xgr.fit(X_train_os, y_train_os, eval_metric="auc", verbose=200)
print(X_train_os.shape, X_train.shape)

predictions = xgr.predict(X_test)
print(
    "Accuracy:", metrics.accuracy_score(y_test, predictions)
)  # accuracy decreased to 79% after balancing
print("Precision:", metrics.precision_score(y_test, predictions))
print("Recall:", metrics.recall_score(y_test, predictions))
print(confusion_matrix(y_test, predictions))
print(classification_report(y_test, predictions))

# Xgboost cross-validation using random search on best params
# CV model
model = xgb()
kfold = KFold(n_splits=10, random_state=7)
results = cross_val_score(model, X, y, cv=kfold)
print("Accuracy: %.2f%% ( std = %.2f%%)" % (results.mean() * 100, results.std() * 100))

# A parameter grid for XGBoost
params = {
    "min_child_weight": [1, 5, 10],
    # 'eta':[0.1,0.15,0.2],
    "n_estimators": [2000, 3000, 5000],
    # 'gamma': [0.5, 1, 1.5, 2, 5],
    "subsample": [0.6, 0.8, 1.0],
    "colsample_bytree": [0.6, 0.8, 1.0],
    "max_depth": [3, 5, 7],
}
## cross validation on best parameter
folds = 5
param_combination = 5
skf = StratifiedKFold(n_splits=folds, shuffle=True, random_state=1001)
random_search = RandomizedSearchCV(
    xgr,
    param_distributions=params,
    n_iter=param_combination,
    scoring="roc_auc",
    n_jobs=4,
    cv=skf.split(X, y),
    verbose=3,
    random_state=1001,
)
## random search on best parameter
random_search.fit(X, y)
## show model best parameter
print(random_search.best_params_)
## xgbclassifier params (using best params from random search)
xgr = xgb(
    n_estimators=3000, max_depth=3, min_child_weight=5, colsample_bytree=1, subsample=1
)
## fit the model to train data set (using oversampling data)
xgr.fit(X_train_os, y_train_os, eval_metric="auc", verbose=200)
predictions = xgr.predict(X_test)
print("Accuracy:", metrics.accuracy_score(y_test, predictions))
print("Precision:", metrics.precision_score(y_test, predictions))
print("Recall:", metrics.recall_score(y_test, predictions))
print(confusion_matrix(y_test, predictions))
print(classification_report(y_test, predictions))

# Note: with the 5-fold grid search with 5-parameter combination, we able find the best parameter and improve the
# overall f1-score on class 1
