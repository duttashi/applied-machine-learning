# -*- coding: utf-8 -*-
"""
Created on Wed Jul 14 11:05:32 2021
Data Source: https://www.kaggle.com/nandalald/turkey-price
@author: Ashish
"""
import pandas as pd
import matplotlib.pyplot as plt
# load data
df1 = pd.read_csv('../../data/kaggle_turkey_foodprice_train.csv')
df2 = pd.read_csv('../../data/kaggle_turkey_foodprice_test.csv')

# merge the data frames
print(df1.shape, df2.shape)
df = pd.concat([df1,df2])
print(df.shape)

# data cleaning

## replace redundant values from column
# reference: https://stackoverflow.com/questions/33413249/how-to-remove-string-value-from-column-in-pandas-dataframe
df['ProductName'] = df.ProductName.str.replace('- Retail','')
print(df.head(5))

## filter values
df = df.query("Place != 'National Average'")
print(df.head(5))
print(df.dtypes)
# univariate plotting
# convert object dtypes to categorical
## reference: https://stackoverflow.com/questions/52404971/get-a-list-of-categories-of-categorical-variable-python-pandas
## TODO: convert all object dtypes to categorical

df['ProductName'] = pd.Categorical(df['ProductName'])

# print all categoris
print(df['ProductName'].cat.categories)

# print unique categoris
print(df['ProductName'].unique())

# univariate visuals
plt.figure(figsize=(15,15))
df['ProductName'].value_counts().plot(kind='barh')
#plt.gca().invert_yaxis()
#plt.show()

df['Place'].value_counts().plot(kind='barh')
#plt.gca().invert_yaxis()
#plt.show()

# One-hot encode the categorical vars
# df_dummies = df.stack().str.get_dummies().sum(level=0)
# print(df_dummies.head(5))

# # Initial model building
# from sklearn.model_selection import cross_val_score, train_test_split
# from sklearn.linear_model import LinearRegression, Lasso, Ridge
# from sklearn.preprocessing import StandardScaler,MinMaxScaler
# from sklearn.metrics import mean_squared_error

# x, y = df_dummies.drop(['Price'],axis=1), df_dummies['Price']

# x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.25)

# print(x_train.shape, x_test.shape)
# model = LinearRegression()
# model.fit(x_train, y_train)
# y_pred_test = model.predict(x_test)
# y_pred_train = model.predict(x_train)
# print("model score test data: ",model.score(x_test, y_test))
# print("model score train: ",model.score(x_train, y_train))
# print("mean square error: ",mean_squared_error(y_test, y_pred_test))

# print([float(i) for i in cross_val_score(LinearRegression(), x, y, cv=10)])

import seaborn as sns
# Plot correlation
plt.figure(figsize = (15, 8))
sns.heatmap(df.corr(), annot = True, linewidths = 1)
plt.show()

plt.figure(figsize = (16, 7))
sns.distplot(df['Price'])
plt.title('Distribution Plot of Product Price\n', fontsize =  20)
plt.show()

# price segmentation with product
price_0_to_20 = df.Price[ (df.Price >=0) & (df.Price <=20)]
price_21_to_40 = df.Price[ (df.Price >=21) & (df.Price <=40)]
price_41_to_60 = df.Price[ (df.Price >=41) & (df.Price <=60)]
price_60above = df.Price[ (df.Price >=61)]

x_Price = ['0-20','21-40','41-60','61+']
y_Price = [ len(price_0_to_20.values), len(price_21_to_40.values),
           len(price_41_to_60.values), len(price_60above.values)] 

import plotly.express as px
import plotly.io as pio

# Will show the plot in browser window
pio.renderers.default='browser'
fig = px.bar(data_frame = df, x = x_Price, y = y_Price, color = x_Price, template = 'plotly_dark',
        labels={'x': "Price", 'y': "Number",'color':'Price group'},
       title = 'Number of products per Price group')
fig.show()



