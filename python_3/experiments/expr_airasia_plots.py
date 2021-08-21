# -*- coding: utf-8 -*-
"""
Created on Fri Feb 12 14:53:14 2021

@author: Ashish
"""

import matplotlib.pyplot as plt
import pandas as pd

df = pd.read_csv(
    "../../data/airasia_ancillary_scoring_insurance.csv", encoding="iso-8859-1"
)
# lowercase all column names
df.columns = map(str.lower, df.columns)
# print(df.columns)
print(df.info())
# change data type of target variable to object
df["ins_flag"] = str(df["ins_flag"])
# print(df.info())
# rename target variable values
df["ins_flag"] = df["ins_flag"].str.replace("0", "no")
df["ins_flag"] = df["ins_flag"].str.replace("1", "yes")

# Plots
df["ins_flag"].value_counts().plot(kind="bar")
