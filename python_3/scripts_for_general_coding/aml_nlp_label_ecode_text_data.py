# -*- coding: utf-8 -*-
"""
Created on Sun Jul 26 11:43:08 2020
In response to a SO Q https://stackoverflow.com/questions/63024842/how-to-assign-labels-score-to-data-using-machine-learning/63096418#63096418
@author: Ashish
"""

# create some dummy data
import pandas as pd
import numpy as np

# create a dictionary
data = {"Date":["1/1/2020","2/1/2020","3/2/2020","4/2/2020","5/2/2020"],
        "ID":[1,2,3,4,5],
        "Tweet":["the weather is sunny",
                 "tom likes harry", "the sky is blue",
                 "the weather is bad","i love apples"]}
# convert data to dataframe
df = pd.DataFrame(data)

from textblob import TextBlob
df['sentiment'] = df['Tweet'].apply(lambda Tweet: TextBlob(Tweet).sentiment)
print(df)

# split the sentiment column into two
df1=pd.DataFrame(df['sentiment'].tolist(), index= df.index)

# append cols to original dataframe
df_new = df
df_new['polarity'] = df1['polarity']
df_new.polarity = df1.polarity.astype(float)
df_new['subjectivity'] = df1['subjectivity']
df_new.subjectivity = df1.polarity.astype(float)
print(df_new)

# add label to dataframe based on condition
conditionList = [
    df_new['polarity'] == 0,
    df_new['polarity'] > 0,
    df_new['polarity'] < 0]
choiceList = ['neutral', 'positive', 'negative']
df_new['label'] = np.select(conditionList, choiceList, default='no_label')
print(df_new)