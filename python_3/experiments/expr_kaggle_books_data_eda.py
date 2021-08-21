# -*- coding: utf-8 -*-
"""
Created on Mon Jan 18 13:43:46 2021
TASK: 

Note : When splitting up the data into training and test sets, you should randomly select (user, book) pairs, not select random users or books. The whole idea is the model be able to predict ratings for books user haven't seen based on the ratings provided for ones you have. If a user is present only in the testing set, the model cannot possibly be basing predictions based on their other ratings.
Predict how each user votes to an unseen book
data source: https://www.kaggle.com/arashnic/book-recommendation-dataset
reference: https://www.kaggle.com/arashnic/recom-i-data-understanding-and-simple-recomm
@author: Ashish
"""

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns, os
import warnings

warnings.filterwarnings("ignore")
pd.set_option("display.max_colwidth", -1)

print(os.getcwd())
# Read data
books = pd.read_csv("../../data/kaggle_booksdata_books.csv")
print(books.head())
