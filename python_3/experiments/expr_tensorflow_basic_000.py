# -*- coding: utf-8 -*-
"""
Created on Wed Dec 23 14:16:10 2020
Tensorflow-  simple example
@author: Ashish
"""
# install tensorflow on Windows 10 as pip install tensorflow --user
import tensorflow as tf


mnist = tf.keras.datasets.mnist
# Load and prepare the MNIST dataset. 
(x_train, y_train),(x_test, y_test) = mnist.load_data()
# Convert the samples from integers to floating-point numbers:
x_train, x_test = x_train / 255.0, x_test / 255.0
# Build the tf.keras.Sequential model by stacking layers. Choose an optimizer and loss function for training:
model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(input_shape=(28, 28)),
  tf.keras.layers.Dense(128, activation='relu'),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)
print(model.evaluate(x_test, y_test))