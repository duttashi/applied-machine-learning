# -*- coding: utf-8 -*-
"""
Created on Sun Sep 20 12:26:18 2020
Exploratory data analysis with Pandas
@author: Ashish
"""
import pandas as pd
import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

# read the data
df = pd.read_csv("../../data/adult.csv")

# EDA
print(df.head)
print(df.info)
print(df.columns)

# .loc selects data only by labels
print(df.loc[:,'sex'].head())
# 1. How many men and women (sex feature) are represented in this dataset?
print(df['sex'].value_counts())
# To calculate fractions, pass normalize=TRUE
print(df['sex'].value_counts(normalize=True))

# Groupby
# Selecting multiple arbitary columns with .loc with slice notation
# df.loc[['name3','name1','name10']]
print(df.loc[:,'sex'].head())
print(df.loc[:,'race':'sex'].head())
print(df[['race','sex','native.country']].head())
print(df.loc[:,['race','sex','native.country']].head())

# 2. What is the average age (age feature) of women?
# Will use the function loc here. loc gets rows (or columns) with particular labels from the index. iloc gets rows (or columns) at particular positions in the index (so it only takes integers).
print(df.loc[df['sex']=='Female','age'].mean())

# 3. What is the percentage of German citizens (native-country feature)?
print(float( (df['native.country']=='Germany').sum())/df.shape[0])

# 4-5. What are the mean and standard deviation of age for those who earn more than 50K per year (salary feature) and those who earn less than 50K per year?¶
age1 = df.loc[df['income']== '>50K','age']
age2 = df.loc[df['income']== '<=50K','age']
print("The average age of rich {0} and std deviation is {1}.... however the average age of poor is {2}, and standard deviation is {3}".\
      format(age1.mean(), age1.std(), age2.mean(), age2.std()
            )
     )
    
# Is it true that people who earn more than 50K have at least high school education? (education – Bachelors, Prof-school, Assoc-acdm, Assoc-voc, Masters or Doctorate feature)¶
print(df.loc[df['income']== '>50K','education'].unique())

# 7. Display age statistics for each race (race feature) and each gender (sex feature). Use groupby() and describe(). Find the maximum age of men of Amer-Indian-Eskimo race.
print(df.groupby(by=['race','sex'])['age'].describe())

# 8. Among whom is the proportion of those who earn a lot (>50K) greater: married or single men (marital-status feature)? Consider as married those who have a marital-status starting with Married (Married-civ-spouse, Married-spouse-absent or Married-AF-spouse), the rest are considered bachelors.

# 9. What is the maximum number of hours a person works per week (hours-per-week feature)? How many people work such a number of hours, and what is the percentage of those who earn a lot (>50K) among them?

# 10. Count the average time of work (hours-per-week) for those who earn a little and a lot (salary) for each country (native-country). What will these be for Japan?