# -*- coding: utf-8 -*-
"""
Created on Sun Jul 18 13:19:44 2021
# reference: https://www.kaggle.com/sootersaalu/amazon-top-50-bestselling-books-2009-2019?select=bestsellers+with+categories.csv
@author: Ashish
"""

import pandas as pd
import seaborn as sns

# load data
df = pd.read_csv("../../data/kaggle_bestseller_books.csv")
print(df.head(5), df.columns, df.shape, df.dtypes)
# print(df.Author.value_counts)

# Seaborn: https://seaborn.pydata.org/tutorial/relational.html
# Univariate plots
sns.set(style="white", color_codes=True)

# scatterplot: should be used when both variables are numeric
sns.relplot(x="Reviews", y="Price", data=df)
# sns.relplot(x="Year", y="Reviews", data=df)
# sns.relplot(x="Year", y="Price", data=df)
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

