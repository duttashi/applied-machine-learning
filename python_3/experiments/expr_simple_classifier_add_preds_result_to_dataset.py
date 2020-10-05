# -*- coding: utf-8 -*-
"""
Created on Mon Oct  5 17:31:16 2020
Objective: create a simple classifier and add predictions to the original dataset.
@author: Ashish
"""

from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.naive_bayes import MultinomialNB
from sklearn.metrics import classification_report,confusion_matrix, accuracy_score
import pandas as pd
import numpy as np

data = load_iris()
#print(data)
# create dataframe
df = pd.DataFrame(data = data.data)
# add outcome variable
df_class = pd.DataFrame(data = data.target)
# print(df_class)
# finally, split into train-test
X_train, X_test, y_train, y_test = train_test_split(df,df_class, train_size = 0.8)

classifier = MultinomialNB()
classifier.fit(X_train, y_train)

pred = classifier.predict(X_test)

print(classification_report(y_test ,pred ))
print('Confusion Matrix: \n', confusion_matrix(y_test,pred))
print()
print('Accuracy: ', accuracy_score(y_test,pred))

y_test['preds'] = pred
df_out = pd.merge(df, y_test[['preds']],
                  how='left', left_index=True,
                  right_index=True)
print(df_out)
