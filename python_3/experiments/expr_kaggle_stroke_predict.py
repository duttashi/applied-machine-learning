# -*- coding: utf-8 -*-
"""
Created on Wed Mar 24 22:44:02 2021

@author: Ashish
"""

import pandas as pd
import warnings
import matplotlib.pyplot as plt

warnings.simplefilter(action="ignore", category=FutureWarning)

# load data
df = pd.read_csv(
    "../../data/kaggle_healthcare-stroke-data.csv",
    index_col="id",
    keep_default_na=False,
    na_values="N/A"
)
# Exploratory data analysis
##  look at data shape, number of cols, column type, missing vals etc
print("Original data shape: ", df.shape)
print(df.info())
# check for missing values
print("missing value count: ")
print(df.isnull().sum())

## look for data inconsistencies
print("\n Observed data inconsistencies")
print(df.gender.value_counts()) # 1 row with Other gender type. drop other

# drop row based on column value
print("\n Observed data inconsistency removed")
df = df[df.gender != "Other"]
print(df.gender.value_counts())

# filter by column value
is_decimal_age = df['age']<1
df_premature_babies_stroke = df[is_decimal_age]
print("\nPremature babies with stroke: ",df_premature_babies_stroke.shape)

# user-defined functions
## 1. function to create a new feature
def label_col(col):
    if col['age']<1:
        return 'premature'
    elif col['age']>1 and col['age']<2:
        return "1 year old"

# 2. function to plot specificed columns of the raw data
def show_raw_visualization(data):
    fig, axes = plt.subplots(nrows=3, ncols=2, figsize=(15, 15), dpi=80)
    for i, key in enumerate(data.columns):
        t_data = data[key]
        ax = t_data.plot(
            ax=axes[i // 2, i % 2],
            title=f"{key.capitalize()}",
            rot=25,
        )

    fig.subplots_adjust(hspace=0.8)
    plt.tight_layout()

# using the custom plotting function
cols_to_plot = ["age", "bmi"]
show_raw_visualization(df[cols_to_plot].iloc[:1000])

    

    