# -*- coding: utf-8 -*-
"""
Created on Sun Jul 18 13:19:44 2021
# reference: https://www.kaggle.com/sootersaalu/amazon-top-50-bestselling-books-2009-2019?select=bestsellers+with+categories.csv
@author: Ashish
"""

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
from sklearn.model_selection import StratifiedShuffleSplit
from pandas.plotting import scatter_matrix # for correlation

# load data
df = pd.read_csv("../../data/kaggle_bestseller_books.csv",
                 dtype = {'Name':'category',
                          'Author':'category',
                          'Genre':'category'})
print("data shape: ",df.shape,
      df.head(5), "\n","Variable\n",df.columns,
      "Variable data types:\n",df.dtypes)
print("\n### Data summary ###")
print("\nNo. of unique authors: ",df['Author'].nunique())
print("\nGenre:\n ", df['Genre'].value_counts(normalize=True))
print("\nUser Rating:\n ", df['User Rating'].describe())


# print(df.Author.value_counts)

# Seaborn: https://seaborn.pydata.org/tutorial/relational.html
# Univariate plots
sns.set(style="white", color_codes=True)

# scatterplot: should be used when both variables are numeric
sns.relplot(x="Reviews", y="Price", data=df)
sns.relplot(x="User Rating", y="Price", data=df)
sns.relplot(x="User Rating", y="Reviews", data=df)
## coloring the points according to a third variable. In seaborn, this is referred to as using a “hue semantic”
# sns.relplot(x="Reviews", y="Price", hue="Genre", data=df)

# lineplot
## lineplot with confidence plot
sns.relplot(x="User Rating", y="Reviews", data=df, kind="line")
## lineplot without confidence plot
sns.relplot(x="User Rating", y="Reviews", data=df, ci=None, kind="line")
## lineplot with density plot
sns.relplot(x="User Rating", y="Reviews", data=df, ci="sd", kind="line");
## To turn off aggregation altogether, set the estimator parameter to None This might produce a strange effect when the data have multiple observations at each point.
sns.relplot(x="User Rating", y="Reviews", data=df, estimator=None, ci="sd", kind="line");
sns.relplot(x="User Rating", y="Reviews", hue = "Price",data=df, kind="line");

# boxplot: for categorical and continuous vars
sns.boxplot(x= 'Genre', y='Reviews' ,data = df)

# histogram: 
## Visualizing distributions of data
#sns.distplot("Price", df)
df.hist( figsize = (20,15))
plt.show()

# Feature Engineering
## create new features

df['user_rating_cat'] = np.ceil( df['User Rating']/1.5)
#print(df['user_rating_cat'].head(10))

# Create a test set

def split_train_test(data, test_ratio):
    np.random.seed(2021) # setting the seed so that it always generates the same shuffled indices.
    shuffled_indices = np.random.permutation(len(data))
    test_set_size = int(len(data) * test_ratio)
    test_indices = shuffled_indices[:test_set_size] 
    train_indices = shuffled_indices[test_set_size:]
    return data.iloc[train_indices], data.iloc[test_indices]

# split the dataset
train_set, test_set = split_train_test(df, 0.2)
print(len(train_set), "train +", len(test_set), "test")


split = StratifiedShuffleSplit(n_splits=1, test_size=0.2, random_state=42)
for train_index, test_index in split.split(df, df["user_rating_cat"]):
    strat_train_set = df.loc[train_index]
    strat_test_set = df.loc[test_index]

print(df['user_rating_cat'].value_counts()/len(df))

# removing the user_rating_cat attribute from stratified set
for set in (strat_train_set, strat_test_set):
    set.drop(['user_rating_cat'], axis=1, inplace=True)
    
## Visualising the stratified training set further
df1 = strat_train_set.copy()

# scatterplot
# df1.plot(kind="scatter", x="Price", y="Reviews", alpha=0.1,
#          s=df["Price"]/100, label="price",
#          c="median_price_value", cmap=plt.get_cmap("jet"), 
#          colorbar=True)
# plt.legend()

## correlations
corr_matrix = df1.corr()
print(corr_matrix)
print(corr_matrix['Price'].sort_values(ascending=False))
## Inference: user rating is negatively coorrelated with reviews, price
attribs = ['Price','User Rating', 'Reviews','Year']
scatter_matrix(df1[attribs], figsize = (12,4))

## drill down in visuals
print(df1.columns)
df1.plot(kind="scatter", x="Price", y="User Rating", alpha=0.1)
df1.plot(kind="scatter", x="Price", y="Reviews")

