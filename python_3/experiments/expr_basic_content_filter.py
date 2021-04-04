# -*- coding: utf-8 -*-
"""
Created on Mon Feb  8 16:14:46 2021
Data source:https://www.kaggle.com/shubhammehta21/movie-lens-small-latest-dataset
Task: To create a simple recommender system
@author: Ashish
"""

import pandas as pd
import matplotlib.pyplot as plt
from surprise import Reader, Dataset
from surprise.model_selection import train_test_split, KFold, LeaveOneOut, GridSearchCV
from surprise import SVD, accuracy

# read the data
df_movies = pd.read_csv("../../data/kaggle_movielens_small_movies.csv")
df_ratings = pd.read_csv("../../data/kaggle_movielens_small_ratings.csv")

# print(df_movies.columns, df_ratings.columns)

# merge the two dataframes on movieID
df_movie_rating = pd.merge(df_movies, df_ratings, on="movieId")
# print(df_movie_rating.shape)

print(df_ratings.columns)
print(df_ratings.rating.value_counts())
# We have four columns userId, moveId, rating and timestamp, and checked the value counts of rating. From here we can see rating of 4.0 has highest value counts. This means more people rated the movie 4.0 has shown in the plot below.
df_ratings.rating.value_counts().plot(kind="bar")
plt.show()
# check for null values
print(df_ratings.isnull().sum())
# create a data subset with only userid, movieid and rating column
df_ratings_subset = df_ratings.drop("timestamp", axis=1)
print(df_ratings_subset.columns)

# Building the recommedation system

reader = Reader()
data = Dataset.load_from_df(df_ratings_subset[["userId", "movieId", "rating"]], reader)
# splitting our dataset in train and test set in a ratio of 75%:25%
trainset, testset = train_test_split(data, test_size=0.25)

# build model
algo = SVD()
algo.fit(trainset)
predictions = algo.test(testset)
print(accuracy.rmse(predictions))  # 0.87% accuracy

# Cross validation and then prediction
# define a cross-validation iterator
kf = KFold(n_splits=5, random_state=22)
print("\nKFold Cross Validation")
for trainset, testset in kf.split(data):
    # train and test algorithm.
    algo.fit(trainset)
    predictions = algo.test(testset)

    # Compute and print Root Mean Squared Error
    accuracy.rmse(
        predictions, verbose=True
    )  # cross validation also gives around 87% accuracy

loo = LeaveOneOut(n_splits=5, random_state=22)
print("\nLeave One Out Cross Validation")
for trainset, testset in loo.split(data):
    # train and test algorithm.
    algo.fit(trainset)
    predictions = algo.test(testset)

    # Compute and print Root Mean Squared Error
    accuracy.rmse(predictions, verbose=True)
# to know which parameter combination yields the best results, the GridSearchCV
# use GridSearchCV scheme

param_grid = {"n_epochs": [5, 10], "lr_all": [0.002, 0.005], "reg_all": [0.4, 0.6]}
gs = GridSearchCV(SVD, param_grid, measures=["rmse", "mae"], cv=3)

gs.fit(data)

# best RMSE score
print("\n Best RMSE score with GridSearch CV: ", gs.best_score["rmse"])

# combination of parameters that gave the best RMSE score
print("\n Best parameter combination with GridSearch CV: ", gs.best_params["rmse"])
