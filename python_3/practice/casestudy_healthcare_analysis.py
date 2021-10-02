# -*- coding: utf-8 -*-
"""
Created on Mon Sep 20 13:59:45 2021
replicate the R analysis for Pfizer case study in python
@author: Ashish
"""
import pandas as pd
import datetime as dt

# load data
df_ccs = pd.read_csv("../../data/ccs.csv")
df_diag = pd.read_csv("../../data/Diagnosis.csv")
df_pres = pd.read_csv("../../data/Prescriptions.csv")
print(df_ccs.shape, df_diag.shape, df_pres.shape)

# lowercase column names
df_ccs.columns = [x.lower() for x in df_ccs.columns]
df_diag.columns = [x.lower() for x in df_diag.columns]
df_pres.columns = [x.lower() for x in df_pres.columns]
print("pres\n", df_pres.columns.values,
      "\nccs\n",df_ccs.columns.values,
      "\ndiag\n",df_diag.columns.values)


# replace column value
df_ccs['diag'] = df_ccs['diag'].str.replace('diag','icd10')

# inner join on icd10
df1 = pd.merge(df_diag, df_ccs, left_on='icd10', 
                right_on='diag')
df_cmbn = pd.merge(df1,df_pres, on="patient_id")
print("Combine dataframe\n", df_cmbn.shape,"\n", df_cmbn.columns)
print(df_cmbn.info())

# change data types
df_cmbn['diag_date'] = pd.to_datetime(df_cmbn['diag_date'])
df_cmbn['prescription_date'] = pd.to_datetime(df_cmbn['prescription_date'])
print(df_cmbn.info())

# check date range
print("\n diags date range: ")
print(df_cmbn['diag_date'].min(),df_cmbn['diag_date'].max() )
print("\n prescrp date range: ")
print(df_cmbn['prescription_date'].min(),df_cmbn['prescription_date'].max() )

# filter date range
df2k15 = df_cmbn[df_cmbn['prescription_date'].dt.year>=2015]
print("\n prescrp date range: ")
print(df2k15['prescription_date'].min(),df2k15['prescription_date'].max() )

# count and sort by coolumn
df1 = df2k15.groupby(['patient_id','ccs_1_desc','ccs_2_desc']).size().reset_index().groupby('patient_id')[[0]].max()
print(df1.head(5))