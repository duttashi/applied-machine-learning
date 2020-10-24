# -*- coding: utf-8 -*-
"""
Created on Fri Oct 23 17:06:09 2020

@author: Ashish
"""

from sklearn.datasets import load_iris

iris = load_iris()
print(type(iris))
print(iris.feature_names)
print(iris.target)
print(iris.target_names) # 0-setosa, 1-versicolor, 2-virginica

print(iris.data.shape)
print(iris.target.shape)

# store feature matrix in X
# X is capitalised because it represents a matrix
X = iris.data
# store response data in y
# y is lowercase because it represents a vector
y = iris.target

# scikit learn 4 step process
# import the class you want to use
import sklearn.neighbours import K
