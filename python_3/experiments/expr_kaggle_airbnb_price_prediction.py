# -*- coding: utf-8 -*-
"""
Created on Thu Oct 29 21:20:47 2020
Data source: https://www.kaggle.com/kritikseth/us-airbnb-open-data 
Task: Predict price
@author: Ashish
"""

# Load required libraries
import pandas as pd
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.impute import SimpleImputer
from sklearn.metrics import mean_squared_error
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import LabelEncoder, OneHotEncoder
from xgboost import XGBRegressor
from sklearn.model_selection import GridSearchCV
# load the data
df = pd.read_csv("../../data/AB_US_2020.csv")

# Exploratory data analysis
##  look at data shape, number of cols, column type, missing vals etc
print("Original data shape: ",df.shape)
print(df.columns)
print(df.head)
print(df.info())
# check for missing values
print("missing value count: ")
print(df.isnull().sum())

# train test split
X = df.drop('price', axis=1)
y = df['price']
X_train, X_valid, y_train, y_valid = train_test_split(X, y, random_state=22)

numerical_cols = [cname for cname in X.columns if 
                X[cname].dtype in ['int64', 'float64']]

categorical_cols = [cname for cname in X.columns if
                    X[cname].nunique() < 50 and 
                    X[cname].dtype in ['object', 'bool']]


numerical_transformer = SimpleImputer(strategy='constant')

categorical_transformer = Pipeline(steps=[
    ('imputer', SimpleImputer(strategy='most_frequent')),
    ('onehot', OneHotEncoder(handle_unknown='ignore'))
])

preprocessor = ColumnTransformer(
    transformers=[
        ('num', numerical_transformer, numerical_cols),
        ('cat', categorical_transformer, categorical_cols)
])

model = XGBRegressor(base_score=0.5, booster='gbtree', colsample_bylevel=1,
             colsample_bynode=1, colsample_bytree=0.6, gamma=0.0, gpu_id=-1,
             importance_type='gain', interaction_constraints='',
             learning_rate=0.02, max_delta_step=0, max_depth=4,
             min_child_weight=0.0,n_estimators=1250, n_jobs=0, num_parallel_tree=1,
             random_state=0,
             reg_alpha=0, reg_lambda=1, scale_pos_weight=1, subsample=0.8,
             tree_method='exact', validate_parameters=1, verbosity=int)

clf = Pipeline(steps=[('preprocessor', preprocessor),
                      ('model', model)
                     ])

clf.fit(X_train, y_train, model__verbose=False) 
preds = clf.predict(X_valid)

print('RMSE:', mean_squared_error(y_valid, preds, squared=False))
#RMSE: 485.05720155432346
# RMSE: 480.4789809666276
preds = clf.predict(X)
output = pd.DataFrame({'id': X.id,
                       'price': preds})
output.to_csv('../../data/AB_US_2020_submission_1.csv', index=False)