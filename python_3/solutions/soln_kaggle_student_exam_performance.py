# -*- coding: utf-8 -*-
"""
Created on Sun Apr 12 16:08:08 2020

@author: Ashish

# Analyse the student performance dataset, hosted on Kaggle
# https://www.kaggle.com/spscientist/students-performance-in-exams/kernels
"""

# import required libraies
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

# Note the usage of relative path in here..
# Since the script is in a folder which is different from the data folder.
# Pandas will start looking from where your current python file is located.
# Therefore you can move from your current directory to where your data is located with '..'
# NOTE: aLL CONSTANT NAMES MUST BE IN UPPERCASE
DATA = pd.read_csv('../../../data/StudentsPerformance.csv')

# Summary statistics
print(DATA.head)
print(DATA.tail)
print(DATA.sample(5))
print(DATA.info())
print(DATA.describe())

# check for missing values
print(DATA.isnull().values.any())
# no missing values
print(DATA.isnull().sum())

# rename the column names. In R, its simple. Use the rename() function like, rename*dataframe_name,"col)old_name","column_new_name")
# In python, use the rename() like df = df.rename(columns={'oldName1': 'newName1', 'oldName2': 'newName2'})
# Remember to assign the result back, as the modification is not-inplace. Alternatively, specify inplace=True
DATA.rename(columns={'race/ethnicity':'race','parental level of education':'parent_edu_level',
                     'test preparation course':'test_prep_score','math score':'score_math',
                     'reading score':'score_reading','writing score':'score_writing'})
# print the column names
print("The column names are: ", DATA.columns)
# Remember to assign the result back, as the modification is not-inplace. Alternatively, specify inplace=True
DATA.rename(columns={'race/ethnicity':'race','parental level of education':'parent_edu_level',
                     'test preparation course':'test_prep_score','math score':'score_math',
                     'reading score':'score_reading','writing score':'score_writing'}, inplace=True)
print("The revised column names are: ", DATA.columns)

# seaborn
# reference: https://www.kaggle.com/kralmachine/seaborn-tutorial-for-beginners
#Gender show bar plot
sns.set(style='whitegrid')
AX = sns.barplot(x=DATA['gender'].value_counts().index,
                 y=DATA['gender'].value_counts().values,
                 palette="Blues_d", hue=['female', 'male'])
plt.legend(loc=8)
plt.xlabel('Gender')
plt.ylabel('Frequency')
plt.title('Show of Gender Bar Plot')
plt.show()

# Bix plot: shows the data distribution between categorical & continuous variable
sns.boxplot(x=DATA['race'], y=DATA['score_math'])
plt.xlabel('Race')
plt.ylabel('math score')
plt.title('Math score distribution by race')
plt.show()

sns.boxplot(x=DATA['parent_edu_level'], y=DATA['score_math'])
plt.xlabel('Parent education level')
plt.ylabel('Math score')
plt.title('Math score distribution by parent education')
plt.show()

# As we can see in the above plot, the x ticks are glued together. To rotate them, use plt.setp(ax.get_xticklabels(), rotation=45)
AX=sns.boxplot(x=DATA['race'], y=DATA['score_math'])
plt.setp(AX.get_xticklabels(), rotation=45)
