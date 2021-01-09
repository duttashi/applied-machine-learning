# -*- coding: utf-8 -*-
"""
Created on Sat Jan  9 15:53:31 2021
Autoregressive Integrated Moving Average (ARIMA)
@author: Ashish
"""
# ARIMA example
from statsmodels.tsa.arima.model import ARIMA
from random import random
# contrived dataset
data = [x + random() for x in range(1, 100)]
# fit model
model = ARIMA(data, order=(1, 1, 1))
model_fit = model.fit()
# make prediction
yhat = model_fit.predict(len(data), len(data), typ='levels')
print(yhat)
