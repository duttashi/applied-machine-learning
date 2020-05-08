# -*- coding: utf-8 -*-
"""
Created on Fri May  8 06:55:48 2020

dataset sourced from: https://www.kaggle.com/doaaalsenani/usa-cers-dataset
@author: Ashish
"""
# required libraries
import pandas as pd
from pandas_profiling import ProfileReport 
import seaborn as sns
import matplotlib.pyplot as plt
import plotly.express as px
from plotly.offline import plot

# installing libraries if they dont exist
# pip install plotly
# pip install pandas_profiling

# Note the usage of relative path in here..
# Since the script is in a folder which is different from the data folder.
# Pandas will start looking from where your current python file is located.
# Therefore you can move from your current directory
# to where your data is located with '..'

# NOTE: aLL CONSTANT NAMES MUST BE IN UPPERCASE
DATA = pd.read_csv('../../data/kaggle_usedcars.csv')
# Summary statistics
print(DATA.head)
print(DATA.tail)
print(DATA.sample(5))
print(DATA.info())
print(DATA.describe())

# EDA
# drop irrelevant columns
DATA.drop('sno', axis=1)

# Data profiling
report = ProfileReport(DATA)
# since I'm using the spyder IDE, so I'll write the profilied output to file
# if your running this code in iPython notebook, then simpky type `report`

# report
# report.to_file('DATA_profile_report.html')

fig = px.treemap(DATA, path=["brand", 'model','color'], color='brand', 
                 hover_data=['model'], color_continuous_scale='rainbow')
# fig.show() # use this code when using IPython notebook
# plot(fig)

# Visualising continuous variables
# How is price distributed
sns.set_style("darkgrid")
sns.kdeplot(data=DATA['price'], label="Price" , shade=True)

# Boxplots for categorical & continuous data
price = DATA.groupby('brand')['price'].max().reset_index()
price = price.sort_values(by="price")
price = price.tail(10)
# df = px.data.tips()
fig = px.box(DATA, x="state", y="price", template="seaborn")
fig.update_traces(quartilemethod="exclusive") # or "inclusive", or "linear" by default
plot(fig)
