# -*- coding: utf-8 -*-
"""py_models.ipynb

Automatically generated by Colaboratory.

Imports
"""

import os
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import tensorflow
import keras
from keras import Sequential
from keras.layers import Dense, Flatten, Activation, Bidirectional, GRU
from keras.models import load_model

print(tf.__version__)

df = pd.read_csv('weather_data.csv')
data = df.values
print(data)

t=data[:,-1]
print(t)

def create_sequences(data, sequence_length):
    sequences = []
    for i in range(len(data) - sequence_length + 1):
        sequence = data[i : i + sequence_length]
        sequences.append(sequence)
    return np.array(sequences)

train_data = t[0:1825]
print(len(train_data))
test_data = t[1825:]
print(len(test_data))

length = 10
sanity_check_row = 5
train_seq = create_sequences(train_data, length)
test_seq = create_sequences(test_data,length)

print(train_seq)
print(train_seq[sanity_check_row])

x_train = train_seq[:, 0:(length - 1)]
y_train = np.reshape(train_seq[:, -1],(-1,1))

print(x_train[sanity_check_row])
print(y_train[sanity_check_row])

x_test = test_seq[:, 0:(length - 1)]
y_test = np.reshape(test_seq[:, -1],(-1,1))

print(x_train.shape)
print(y_train.shape)

model = Sequential()
model.add(Dense(12,input_dim=(9),activation='relu'))
model.add(Dense(8,activation='linear'))
model.add(Dense(1))

model.summary()

model.compile(optimizer='adam', loss='mae')

x_train = x_train.astype('float32')
y_train = y_train.astype('float32')
x_test = x_test.astype('float32')
y_test = y_test.astype('float32')

print(y_train)

history = model.fit(
    x_train, y_train,
    epochs=20,
    batch_size=32,
    validation_data=(x_test, y_test),
    verbose=1
)

x_new = np.array([[226,207,205,218,209,203,183,206,224]])
y_new = model.predict(x_new)
print(y_new[0])

model.save('simple_model_py.h5')

model = load_model('simple_model.h5')

converter = tensorflow.lite.TFLiteConverter.from_keras_model(model)

converter.optimizations = [tensorflow.lite.Optimize.DEFAULT]
converter.experimental_new_converter=True
converter.target_spec.supported_ops = [tensorflow.lite.OpsSet.TFLITE_BUILTINS,
tensorflow.lite.OpsSet.SELECT_TF_OPS]

tflite_model = converter.convert()

open('py_model_sample.tflite','wb').write(tflite_model)

interpreter = tf.lite.Interpreter(model_path = 'tflitemodel_sample')
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()
print("Input shape:", input_details[0]['shape'])
print("Input type:", input_details[0]['dtype'])
print("Output shape:", output_details[0]['shape'])
print("Output type:", output_details[0]['dtype'])

interpreter.get_input_details()

input_data = np.array([[226], [207], [205], [218], [209], [203], [183], [206], [224]], dtype=np.float32)
input_data = input_data.reshape((1, 9, 1))  # Reshape to match [1, 9, 1]

input_data

interpreter.allocate_tensors()
interpreter.set_tensor(input_details[0]['index'],input_data)
interpreter.invoke()
interpreter.get_tensor(output_details[0]['index'])