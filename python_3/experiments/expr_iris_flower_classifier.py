# -*- coding: utf-8 -*-
"""
Created on Tue Oct 20 12:42:42 2020

@author: Ashish
"""
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
iris_dat = load_iris()
X_train, X_test, y_train, y_test = train_test_split(iris_dat['data'],
                                                    iris_dat['target'],
                                                    random_state=0)
# print("Original data shape", iris_dat.shape)
print("Train data shape: ", X_train.shape)
print("Test data shape: ", X_test.shape)
# print("Labels: ", y_train)

# create a pandas dataframe
import pandas as pd
iris_df = pd.DataFrame(X_train, columns= iris_dat.feature_names)
import matplotlib.pyplot as plt
plt.scatter(X_train,y_train)
