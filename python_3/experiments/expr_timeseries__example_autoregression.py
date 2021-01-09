# -*- coding: utf-8 -*-
"""
Created on Sat Jan  9 15:53:51 2021
Autoregressive Moving Average (ARMA)
@author: Ashish
"""
# ARMA example
from statsmodels.tsa.arima.model import ARIMA
from random import random
# contrived dataset
data = [random() for x in range(1, 100)]
# fit model
model = ARIMA(data, order=(2, 0, 1))
model_fit = model.fit()
# make prediction
yhat = model_fit.predict(len(data), len(data))
print(yhat)
