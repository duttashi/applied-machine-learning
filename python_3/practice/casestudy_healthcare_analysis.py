# -*- coding: utf-8 -*-
"""
Created on Mon Sep 20 13:59:45 2021
replicate the R analysis for Pfizer case study in python
@author: Ashish
"""
import pandas as pd

# load data
df_ccs = pd.read_csv("../../data/ccs.csv")
df_diag = pd.read_csv("../../data/Diagnosis.csv")
df_pres = pd.read_csv("../../data/Prescriptions.csv")
print(df_ccs.shape, df_diag.shape, df_pres.shape)
print("Column names\n", df_pres.columns.values,
      "\n",df_ccs.columns.values,
      "\n",df_diag.columns.values)
def lowercase(dataframe):
    return [x.lower() for x in dataframe.columns]

df_ccs = lowercase(df_ccs)
print(df_ccs.columns.values)

