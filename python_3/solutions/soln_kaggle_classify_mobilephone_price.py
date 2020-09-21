# -*- coding: utf-8 -*-
"""
Created on Thu Jul  2 17:40:28 2020

@author: Ashish
Objective: To predict the price-range of mobile phones
Data Source: https://www.kaggle.com/prajwal17/mobile-price-prediction-project?
"""
# load the required libraries
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC
import numpy as np
import matplotlib.pyplot as plt
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import f_classif
from sklearn.model_selection import GridSearchCV

# Now read the data and store it in a dataframe
mobile_train = pd.read_csv("../../data/kaggle_mobile_price_train.csv")
mobile_test = pd.read_csv("../../data/kaggle_mobile_price_test.csv")

# MODEL BUILDING
X=mobile_train.drop('price_range',axis=1)
y=mobile_train['price_range']
# Splitting the data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.33, random_state=101)

# Creating a SVM Model

svm=SVC(random_state=1)
svm.fit(X_train,y_train)
print("\n####### SVM model ########\n")
print("train accuracy:",svm.score(X_train,y_train))
print("test accuracy:",svm.score(X_test,y_test))

## Feature Selection for Second Model

accuracy_list_train = []
k=np.arange(1,21,1)
for each in k:
    X_new = SelectKBest(f_classif, k=each).fit_transform(X_train, y_train)
    svm.fit(X_new,y_train)
    accuracy_list_train.append(svm.score(X_new,y_train))   
    
plt.plot(k,accuracy_list_train,color="green",label="train")
plt.xlabel("k values")
plt.ylabel("train accuracy")
plt.legend()
plt.show()

# In the graph above, we can see 4 or 5 features gives higher train accuracies.

d = {'best features number': k, 'train_score': accuracy_list_train}
df = pd.DataFrame(data=d)
print("max accuracy:",df["train_score"].max())
print("max accuracy id:",df["train_score"].idxmax())
print(" max accuracy values: \n", df.iloc[4])

# I used 5 features because it has the highest accuracy.
# Now let's determine our features:

selector = SelectKBest(f_classif, k = 5)
x_new = selector.fit_transform(X_train, y_train)
x_new_test=selector.fit_transform(X_test,y_test)
names_train = X_train.columns.values[selector.get_support()]
names_test = X_test.columns.values[selector.get_support()]
print("X train features:",names_train) # 95% accuracy
print("X test features:",names_test) # 94% accuracy

########## Note: GridSearchCV takes a long time
# ## Hyperparameter Tuning using GridSearch CV for SVM model
# C=[1,0.1,0.25,0.5,2,0.75]
# kernel=["linear","rbf"]
# gamma=["auto",0.01,0.001,0.0001,1]
# decision_function_shape=["ovo","ovr"]
# svm=SVC(random_state=1)
# paramSet = dict(kernel=kernel,C=C, gamma=gamma, decision_function_shape=decision_function_shape)
# grid_svm=GridSearchCV(estimator=svm,cv=5,
#                       param_grid= paramSet,
#                       n_jobs=2, pre_dispatch=1, verbose=5)
# grid_svm.fit(x_new,y_train) # Total processing time: 31.8 mins, 600 fits
# print("best score: ", grid_svm.best_score_) # 0.9738805970149255
# print("best param: ", grid_svm.best_params_) # {'C': 1, 'decision_function_shape': 'ovo', 'gamma': 'auto', 'kernel': 'linear'}
##########

svm_model=SVC(C=1,decision_function_shape="ovo",gamma="auto",kernel="linear",random_state=1)
svm_model.fit(x_new,y_train)
print("train_accuracy:",svm_model.score(x_new,y_train))
print("test_accuracy: ", svm_model.score(x_new_test,y_test))