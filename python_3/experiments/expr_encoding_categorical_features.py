# -*- coding: utf-8 -*-
"""
Created on Sun Sep 20 12:16:07 2020
Encoding categorical features
Reference: https://contrib.scikit-learn.org/category_encoders/
@author: Ashish
"""

# The objective of this notebook is to demonstrate feature encoding strategies
# pip install category_encoders

# import the packages
import pandas as pd
import category_encoders as ce
from sklearn.preprocessing import LabelEncoder

# make some data
df = pd.DataFrame({
 'id':[10,20,30,40,50],
 'gender':["male","female","female","male","female"],
 'mood':["happy","sad","happy","sad","happy"],
 'outcome':[1, 1,0,0,0]})
print("\n Original dataframe:\n",df)
# Encooding categorical data

encoder = LabelEncoder()
# df_cat = df['gender']
df_cat_encoded = encoder.fit_transform(df['gender'])
print("Encoded categorical vars\n",df_cat_encoded)
df1 = encoder.fit_transform(df_cat_encoded.reshape(-1,1))
print("Encoded categorical vars\n",df1)
print("\nEncoding classes: ", encoder.classes_)

# instantiate an encoder - here we use Binary()
ce_binary = ce.BinaryEncoder()
print("\n### Binary Encoding ###\n", ce_binary.fit_transform(df))

# fit and transform and presto, you've got encoded data
#print(ce_binary.fit_transform(df))
# instantiate an encoder - here we use one_hot()
ce_one_hot = ce.OneHotEncoder()
print("\n### One-Hot Encoding ###\n",ce_one_hot.fit_transform(df))

# Ordinal Encoding
ce_ord_encod = ce.OrdinalEncoder()
print("\n### Ordinal Encoding ###\n",ce_ord_encod.fit_transform(df))
