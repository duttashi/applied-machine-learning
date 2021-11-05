# -*- coding: utf-8 -*-
"""
Created on Fri Nov  5 16:31:05 2021
Objective: basic deep learning code
reference: https://keras.io/getting_started/intro_to_keras_for_engineers/
images reference: downloaded from google images
@author: Ashish
"""

import tensorflow as tf
from tensorflow import keras
import numpy as np
tf.get_logger().setLevel('INFO')
print("TensorFlow version:", tf.__version__)

# img directory
import os
print(os.getcwd())

# Create a dataset.
dataset = keras.preprocessing.image_dataset_from_directory(
  '../../data', batch_size=64, image_size=(200, 200))


# For demonstration, iterate over the batches yielded by the dataset.
for data, labels in dataset:
   print(data.shape)  # (7,200, 200,3)
   print(data.dtype)  # float32
   print(labels.shape)  # (7,)
   print(labels.dtype)  # int32
   


