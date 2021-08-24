#data source: https://www.kaggle.com/adityakadiwal/water-potability

import pandas as pd

# load data
df = pd.read_csv("../../data/kaggle_water_potability.csv")
print(df.shape)
print(df.head(5))

# check for missing values
print("missing value count: ")
print(df.isnull().sum())
