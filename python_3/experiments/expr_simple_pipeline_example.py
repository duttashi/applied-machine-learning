# -*- coding: utf-8 -*-
"""
Created on Sat Oct 31 14:39:05 2020

@author: Ashish
"""

from sklearn.datasets import make_regression,make_classification

from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split

from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
import warnings
warnings.filterwarnings("ignore")

# create sample data
X, y = make_classification(n_samples=100,n_features=10,n_informative=2)

X_train, X_test, y_train, y_test = train_test_split( X, y, test_size=0.33, random_state=22)
print(" X train shape: ",X_train.shape, "\n X test shape:",X_test.shape," \n y train shape:", y_train.shape,"\n y test shape:", y_test.shape)

# Pipeline: it takes a list of tuples as parameter
pipeline_1 = Pipeline([
    ('scaler',StandardScaler()),
    ('clf', LogisticRegression())
])
# use the pipeline object as you would
# a regular classifier
pipeline_1.fit(X_train,y_train)
y_preds = pipeline_1.predict(X_test)
print(y_preds)
ac_score = accuracy_score(y_test,y_preds)
print("Log reg: ",ac_score)

#Another  Pipeline: it takes a list of tuples as parameter
pipeline_2 = Pipeline([
    ('scaler',StandardScaler()),
    ('clf', SVC())
])
# use the pipeline object as you would
# a regular classifier
pipeline_2.fit(X_train,y_train)
y_preds = pipeline_2.predict(X_test)
print(y_preds)
ac_score = accuracy_score(y_test,y_preds)
print("SVM classifier: ",ac_score)

# Another Example
from sklearn.preprocessing import LabelBinarizer
bin = LabelBinarizer()  #first we initialize
vec = ['cat', 'dog', 'dog', 'dog'] #we have our label list we want binarized
bin.fit(vec)
print (bin.classes_)
print (bin.transform(vec))