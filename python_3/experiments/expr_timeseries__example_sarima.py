# -*- coding: utf-8 -*-
"""
Created on Sat Jan  9 15:56:27 2021
Seasonal Autoregressive Integrated Moving-Average (SARIMA)
It combines the ARIMA model with the ability to perform the same autoregression, differencing, and moving average modeling at the seasonal level.

@author: Ashish
"""
# SARIMA example
from statsmodels.tsa.statespace.sarimax import SARIMAX
from random import random
# contrived dataset
data = [x + random() for x in range(1, 100)]
# fit model
model = SARIMAX(data, order=(1, 1, 1), seasonal_order=(0, 0, 0, 0))
model_fit = model.fit(disp=False)
# make prediction
yhat = model_fit.predict(len(data), len(data))
print(yhat)


