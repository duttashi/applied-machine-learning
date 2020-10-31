# -*- coding: utf-8 -*-
"""
Created on Sat Oct 31 08:40:49 2020

@reference: https://www.kaggle.com/ashishdutt/exercise-introduction/edit
"""

import pandas as pd
from sklearn.model_selection import train_test_split

# Read the data
X_full = pd.read_csv('../../data/kaggle_house_price_pred_train.csv', index_col='Id')
X_test_full = pd.read_csv('../../data/kaggle_house_price_pred_train.csv', index_col='Id')

# show few lines
print(X_full.head())
print(X_test_full.head())
# Obtain target and predictors
y = X_full.SalePrice
features = ['LotArea', 'YearBuilt', '1stFlrSF', '2ndFlrSF', 'FullBath', 'BedroomAbvGr', 'TotRmsAbvGrd']
# create a dataframe with only the selected features from above
X = X_full[features].copy()
print(X.head())
X_test = X_test_full[features].copy()

# Break off validation set from training data
X_train, X_valid, y_train, y_valid = train_test_split(X, y, train_size=0.8, test_size=0.2,
                                                      random_state=0)
# Step 1: Evaluate several models
from sklearn.ensemble import RandomForestRegressor

# Define the models
model_1 = RandomForestRegressor(n_estimators=50, random_state=0)
model_2 = RandomForestRegressor(n_estimators=100, random_state=0)
model_3 = RandomForestRegressor(n_estimators=100, criterion='mae', random_state=0)
model_4 = RandomForestRegressor(n_estimators=200, min_samples_split=20, random_state=0)
model_5 = RandomForestRegressor(n_estimators=100, max_depth=7, random_state=0)

models = [model_1, model_2, model_3, model_4, model_5]

# To select the best model out of the five, we define a function score_model() below. This function returns the mean absolute error (MAE) from the validation set. Recall that the best model will obtain the lowest MAE.
from sklearn.metrics import mean_absolute_error

# Function for comparing different models
def score_model(model, X_t=X_train, X_v=X_valid, y_t=y_train, y_v=y_valid):
    model.fit(X_t, y_t)
    preds = model.predict(X_v)
    return mean_absolute_error(y_v, preds)

for i in range(0, len(models)):
    mae = score_model(models[i])
    print("Model %d MAE: %d" % (i+1, mae)) # clearly model_3 is the best with lowest MAE of 23528

# Step 2: Generate Test Predictions
# Define a model
my_model = RandomForestRegressor(n_estimators=100, criterion='mae', random_state=0)

# Fit the model to the training data
my_model.fit(X, y)

# Generate test predictions
preds_test = my_model.predict(X_test)
# print(preds_test.head())

# Save predictions in format used for competition scoring
output = pd.DataFrame({'Id': X_test.index,'SalePrice': preds_test})
output.to_csv('../../data/kaggle_house_price_pred_submission.csv', index=False)
# The leaderboard score is ..

# Approach 2: Try another regressor
from sklearn.tree import DecisionTreeRegressor
my_model_dtr = DecisionTreeRegressor(random_state=0)
# Fit the model to the training data
my_model_dtr.fit(X, y)
mae = score_model(my_model_dtr)
print("DTR Model MAE: " , mae)
    
# Generate test predictions
preds_test = my_model_dtr.predict(X_test)
# print(preds_test.head())

# Step 3: Missing values imputation to improve the leaderboard score

