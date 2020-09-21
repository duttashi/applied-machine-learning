# -*- coding: utf-8 -*-
"""
Created on Sun Sep 20 12:16:07 2020
Encoding categorical features
@author: Ashish
"""

# The objective of this notebook is to demonstrate feature encoding strategies
# pip install category_encoders

# import the packages
import pandas as pd
import category_encoders as ce

# make some data
df = pd.DataFrame({
 'id':[10,20,30,40,50],
 'gender':["male","female","female","male","female"],
 'mood':["happy","sad","happy","sad","happy"],
 'outcome':[1, 1,0,0,0]})

print(df)
# instantiate an encoder - here we use Binary()
ce_binary = ce.BinaryEncoder()
# fit and transform and presto, you've got encoded data
print(ce_binary.fit_transform(df))
# instantiate an encoder - here we use one_hot()
ce_one_hot = ce.OneHotEncoder()
print(ce_one_hot.fit_transform(df))
