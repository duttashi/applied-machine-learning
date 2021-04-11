# -*- coding: utf-8 -*-
"""
Created on Sun Oct 25 08:12:59 2020

@author: Ashish
"""

# load the required libraries
import pandas as pd
from sklearn.preprocessing import OrdinalEncoder

# import custom functions from different folder
# from python_3.helpful_functions.train_valid_test_split import train_validate_test_split
from sklearn.model_selection import train_test_split
from sklearn.tree import DecisionTreeClassifier
from sklearn.metrics import confusion_matrix

# load the required data
df = pd.read_csv("../../data/adult.csv")
# Exploratory data analysis
##  look at data shape, number of cols, column type, missing vals etc
print("Original data shape: ", df.shape)
print(df.columns)
print(df.head)
# Observations: assign column names, remove irrelevant cols
col_header = [
    "age",
    "workclass",
    "fnlwgt",
    "education",
    "education-num",
    "marital-status",
    "occupation",
    "relationship",
    "race",
    "sex",
    "capital-gain",
    "capital-loss",
    "hours-per-week",
    "native-country",
    "salary",
]
# assign column headers
df.columns = col_header
print(df.columns)

# remove irrelevant cols based on theri index number
# NOTE: Pandas column indexing begins from ZERO and not from One.
drop_cols = [2, 4, 10, 11]
df.drop(df.columns[drop_cols], axis=1, inplace=True)
print("reduced data shape: ", df.shape)
print("reduced data columns: ", df.columns)

# check for missing values
print("missing value count: ")
print(df.isnull().sum())  # No missing values

# convert categorical cols to numerical format

# 1. check for column data types
print("Column data types: ", df.dtypes)
# 2. Convert selected object data types to category data type
cat_cols = [
    "workclass",
    "education",
    "marital-status",
    "occupation",
    "relationship",
    "race",
    "sex",
    "native-country",
    "salary",
]
# 2. select all categorical columns using select.dtypes()
df = df[cat_cols].astype("category")
print("Revised column data types ", df.columns)

# revalue column values
# df['salary'] = df['salary'].map({'>50K': "above_50K", '<=50K': "less_equal_50K"})
# df['salary'].replace(to_replace=dict('>50K': 'above_50K', '<=50K':'les_eq_50K'), inplace=True)
# df['salary'].replace('>50K','above_50K', inplace=True)
# df['salary'].replace('<=50K','less_eq_50K', inplace=True)
# df['salary'].replace(['>50K','<=50K'],['above_50K','less_eq_50K'],inplace=True)
# print(df.head)
# check for high correlated variables

# use ordinal encoder to convert categorical to numbers

enc = OrdinalEncoder()
df[cat_cols] = enc.fit_transform(df[cat_cols])
print(df.head)
print(enc.categories_)

# Model Building
# train_set, validate_set, test_set = train_validate_test_split(df)
# print("Train set: ", train_set.shape)
# print("Test set: ", test_set.shape)
# print("Validate set: ", validate_set.shape)
#
# print("Dataframe cols: ", df.columns)

# X_train_data = train_set[['workclass', 'education', 'marital-status', 'occupation',
#        'relationship', 'race', 'sex', 'native-country']].copy()
# y_train_label = train_set[['salary']].copy()


# create training and testing vars
X = df[
    [
        "workclass",
        "education",
        "marital-status",
        "occupation",
        "relationship",
        "race",
        "sex",
        "native-country",
    ]
].copy()
y = df[["salary"]].copy()
X_train, X_test, y_train, y_test = train_test_split(df, y, test_size=0.2)
print(X_train.shape, y_train.shape)
print(X_test.shape, y_test.shape)

# Decision Tree classifier
clf = DecisionTreeClassifier(criterion="entropy", max_depth=1, random_state=22)
# fit training data
clf.fit(X_train, y_train)
# make prediction
y_pred = clf.predict(X_test)
print("Finding the training and test set accuracy")
print("Training Accuracy: ", clf.score(X_train, y_train))
print("Testing Accuracy: ", clf.score(X_test, y_test))

# printing the confusion matrix
cm = confusion_matrix(y_test, y_pred)
print(cm)
