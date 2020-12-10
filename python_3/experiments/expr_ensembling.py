# -*- coding: utf-8 -*-
"""
Created on Sat Oct 10 21:23:32 2020

"""

import lightgbm as lgbm
import numpy as np
from sklearn import datasets, metrics, model_selection
from .helpful_functions.ensemble import *
X, y = datasets.load_breast_cancer(return_X_y=True)
n_splits = 5
cv = model_selection.KFold(n_splits=5, shuffle=True, random_state=42)
params = {
 'objective': 'binary',
    'metric': 'auc',
     'verbosity': -1
 }
single_scores = np.zeros(n_splits)
with_cv_scores = np.zeros(n_splits)

for i, (fit_idx, val_idx) in enumerate(cv.split(X, y)):

     X_fit = X[fit_idx]
     y_fit = y[fit_idx]
     X_val = X[val_idx]
     y_val = y[val_idx]
     fit_set = lgbm.Dataset(X_fit, np.log1p(y_fit))
     val_set = lgbm.Dataset(X_val, np.log1p(y_val))

     # Train a single LGBM
     model = lgbm.train(
         params=params,
         train_set=fit_set,
         valid_sets=(fit_set, val_set),
         num_boost_round=30,
         verbose_eval=False,
         early_stopping_rounds=5,
         )
single_scores[i] = metrics.roc_auc_score(y_val, model.predict(X_val))
# Train a LGBM CV
model = helpful_functions.ensemble.LGBMCV(
    cv=model_selection.KFold(3, shuffle=True, random_state=42),
    **params
    )
model = model.fit(
    X_fit, y_fit,
    num_boost_round=30,
    verbose_eval=False,
    early_stopping_rounds=5,
    )
with_cv_scores[i] = metrics.roc_auc_score(y_val, model.predict(X_val))
print('LGBM without CV AUC: {:.5f} (+/- {:.5f})'.format(single_scores.mean(), single_scores.std()))
print('LGBM with CV AUC: {:.5f} (+/- {:.5f})'.format(with_cv_scores.mean(), with_cv_scores.std()))