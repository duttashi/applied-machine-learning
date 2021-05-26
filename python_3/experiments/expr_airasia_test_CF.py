# -*- coding: utf-8 -*-
"""
Created on Wed Feb 10 08:38:55 2021
Feature Selection 
@author: Ashish
"""

import pandas as pd, matplotlib.pyplot as plt, seaborn as sns
from sklearn.preprocessing import LabelEncoder
from sklearn.feature_selection import SelectKBest
from sklearn.feature_selection import chi2

from surprise import SVD, KNNBasic, Reader, Dataset

df = pd.read_csv(
    "../../data/airasia_ancillary_scoring_insurance.csv", encoding="iso-8859-1"
)
print(df.shape)
# print(df.columns)
# rearrange the cols such that target var is last
# cols = [col for col in df if col!='INS_FLAG'] + ['INS_FLAG']
# df = df[cols]
# rearrange cols such that categorical are first, followed by continuous and then target var
df = df[
    [
        "SALESCHANNEL",
        "TRIPTYPEDESC",
        "flight_day",
        "ROUTE",
        "geoNetwork_country",
        "BAGGAGE_CATEGORY",
        "SEAT_CATEGORY",
        "FNB_CATEGORY",
        "Id",
        "PAXCOUNT",
        "PURCHASELEAD",
        "LENGTHOFSTAY",
        "flight_hour",
        "flightDuration_hour",
        "INS_FLAG",
    ]
]
print(df.columns)
print(df.shape)

# Encoding categorical data
# creating instance of labelencoder
labelencoder = LabelEncoder()

# Assigning numerical values and storing in new label column
df["ROUTE"] = labelencoder.fit_transform(df["ROUTE"])
df["geoNetwork_country"] = labelencoder.fit_transform(df["geoNetwork_country"])
df["flight_day"] = labelencoder.fit_transform(df["flight_day"])
df["TRIPTYPEDESC"] = labelencoder.fit_transform(df["TRIPTYPEDESC"])
df["SALESCHANNEL"] = labelencoder.fit_transform(df["SALESCHANNEL"])

# print(df.columns)

# Univariate Feature Selection: Statistical tests can be used to select those features that have the strongest relationship with the output variable.
X = df.iloc[:, 1:8]  # independent categorical cols
y = df.iloc[:, -1]  # target col
# print(X)
# print(y)

# https://www.analyticsvidhya.com/blog/2020/10/feature-selection-techniques-in-machine-learning/
# apply SelectKBest class to extract top 7 best features
bestfeatures = SelectKBest(score_func=chi2, k="all")
fit = bestfeatures.fit(X, y)
dfscores = pd.DataFrame(fit.scores_)
dfcolumns = pd.DataFrame(X.columns)
# concat two dataframes for better visualization
featureScores = pd.concat([dfcolumns, dfscores], axis=1)
featureScores.columns = ["Specs", "Score"]  # naming the dataframe columns
print(featureScores.nlargest(10, "Score"))  # print  best features

# subset the features with high importance
df_impvars = df[
    [
        "Id",
        "geoNetwork_country",
        "ROUTE",
        "SEAT_CATEGORY",
        "BAGGAGE_CATEGORY",
        "FNB_CATEGORY",
        "flight_day",
        "INS_FLAG",
    ]
]

df_impvars_dict = df_impvars.set_index("Id").T.to_dict("dict")
# df_impvars_dict = df_impvars.set_index(['Id','INS_FLAG']).stack().unstack([0,1])
# df_impvars_new = df_impvars.set_index(['Id','INS_FLAG']).stack().unstack()
# print(df_impvars_dict.keys())
# split the dictionary
# data1 = [df_impvars_dict["INS_FLAG"][idx] for idx, x in enumerate(df_impvars_dict["INS_FLAG"])]


df_new = pd.DataFrame.from_dict(df_impvars_dict, orient="index")
print("\n############\n")
print(df_new.columns)
# print(df_new.head)
# df_new.to_csv("../../data/airasia_ancillary_scoring_insurance_dict.csv")

# import csv
# with open('../../data/airasia_ancillary_scoring_insurance_dict_1.csv', 'w') as csv_file:
#     writer = csv.writer(csv_file)
#     for key, value in df_impvars_new.items():
#        writer.writerow([key, value])


# split dictionary based on value
# df_new = [ df_impvars_dict['Id','geoNetwork_country', 'ROUTE','SEAT_CATEGORY',
#              'BAGGAGE_CATEGORY','FNB_CATEGORY'][idx] for idx, x in enumerate(df_impvars_dict["Id"]) ]
# print(df_new)


# print(df_impvars_dict)
# write to disc
# df_impvars_dict.to_csv('../../data/airasia_ancillary_scoring_insurance_dict.csv')

# df_new = pd.read_csv('../../data/airasia_ancillary_scoring_insurance_dict.csv')
# DF = pd.DataFrame()
# for key in df_new.keys():
#     df = pd.DataFrame(columns=['User', 'Item', 'Rating'])
#     df['Rating'] = pd.Series(df_impvars_dict[key])
#     df['Item'] = pd.DataFrame(df.index)
#     df['User'] = key

#     DF = pd.concat([DF, df], axis = 0)

# DF = DF.reset_index(drop=True)
# print(DF)

# print("\n Important vars\n", df_impvars.columns)
# df_impvars = df.iloc[:4:5]

# Feature selection for continuous variables using Pearsons Correlation metric
# The correlation coefficient has values between -1 to 1
# — A value closer to 0 implies weaker correlation (exact 0 implying no correlation)
# — A value closer to 1 implies stronger positive correlation
# — A value closer to -1 implies stronger negative correlation
# Using Pearson Correlation
# plt.figure(figsize=(12,10))
# # df_cont = df.iloc[:, 10:14]
# cor = df.iloc[:, 10:15].corr()
# sns.heatmap(cor, annot=True, cmap=plt.cm.Reds)
# plt.show()

# #Correlation with output variable
# cor_target = abs(cor["INS_FLAG"])
# #Selecting highly correlated features
# relevant_features = cor_target[cor_target>0.5]
# print(relevant_features)

# https://nbviewer.jupyter.org/github/NicolasHug/Surprise/blob/master/examples/notebooks/KNNBasic_analysis.ipynb

# first convert pandas dataframe to dictionary format so that Surpise dataset( is able to parse it)
# df_impvars_dict = df_impvars.set_index('Id').T.to_dict('list')
# https://stackoverflow.com/questions/63302528/how-to-load-pandas-dataframe-into-surprise-dataset

# reader = Reader()
# df_surp_vars = df[['Id','geoNetwork_country','INS_FLAG']]
# df_surprise = Dataset.load_from_df(df_surp_vars, reader)
