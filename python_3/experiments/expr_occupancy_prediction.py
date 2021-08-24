# Obkective: Room occupany prediction based on environmental factors

from pandas import read_csv
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split
# from sklearn.metrics import accuracy_score
from pandas import concat
# import os
# load all data
# print(os.getcwd())
data1 = read_csv('../../data/datatest.txt', header=0, index_col=1, parse_dates=True, squeeze=True)
data2 = read_csv('../../data/datatraining.txt', header=0, index_col=1, parse_dates=True, squeeze=True)
data3 = read_csv('../../data/datatest2.txt', header=0, index_col=1, parse_dates=True, squeeze=True)
# vertically stack and maintain temporal order
data = concat([data1, data2, data3])
# drop row number
# data.drop('no', axis=1, inplace=True)
# save aggregated dataset
data.to_csv('../../data/combined.csv')

# load the dataset
data = read_csv('../../data/combined.csv', header=0, index_col=0, parse_dates=True, squeeze=True)
values = data.values
# split data into inputs and outputs
X, y = values[:, :-1], values[:, -1]
# split the dataset
trainX, testX, trainy, testy = train_test_split(X, y, test_size=0.3, shuffle=False, random_state=1)
 
# make a naive prediction
def naive_prediction(testX, value):
	return [value for x in range(len(testX))]
 
# evaluate skill of predicting each class value
for value in [0, 1]:
	# forecast
	yhat = naive_prediction(testX, value)
	# evaluate
	score = accuracy_score(testy, yhat)
	# summarize
	print('Naive=%d score=%.3f' % (value, score))
    