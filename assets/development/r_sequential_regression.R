library(dplyr)
library(MASS)
library(tensorflow)
library(keras)
library(caret)

setwd('C:/DEV/Flutter-Weather/sample_data')

d <- read.csv('weather_data.csv')

df <- data.matrix(d %>% dplyr::select(value))
head(df)

train_data <- df
mean <- mean(train_data[,1])
std <- sd(train_data[,1])
data <- scale(df[,1], center = mean, scale = std)

train_data <- data[1:1825]
test_data <- data[1826:2186]

train_size <- 0.8  # Percentage of data for training

# Create sequences for time series forecasting
sequence_length <- 10  # Sequence length for input

# Function to create sequences from data
create_sequences <- function(data, sequence_length) {
  sequences <- list()
  for (i in 1:(length(data) - sequence_length)) {
    sequence <- data[i:(i + sequence_length - 1)]
    sequences[[i]] <- sequence
  }
  return(do.call(rbind, sequences))
}

# Create sequences for training and testing data
train_sequences <- create_sequences(train_data, sequence_length)
test_sequences <- create_sequences(test_data, sequence_length)

# Split sequences into input and output (X and y)
X_train <- train_sequences[, 1:(sequence_length - 1)]
y_train <- train_sequences[, sequence_length]

X_test <- test_sequences[, 1:(sequence_length - 1)]
y_test <- test_sequences[, sequence_length]

# Reshaping input data to fit the model
# Reshape X_train and X_test to have 3D shape: (samples, sequence_length - 1, 1)
X_train_reshaped <- array(X_train, dim = c(dim(X_train)[1], dim(X_train)[2], 1))
X_test_reshaped <- array(X_test, dim = c(dim(X_test)[1], dim(X_test)[2], 1))


# Define Keras model
model <- keras_model_sequential()
model %>%
  layer_lstm(units = 50, return_sequences = FALSE, input_shape = c(sequence_length - 1, 1)) %>%
  layer_lstm(units = 50) %>%
  layer_dense(units = 1)

# Compile the model
model %>% compile(
  loss = 'mae',
  optimizer = optimizer_adam()
)

# Train the model
history <- model %>% fit(
  X_train, y_train,
  epochs = 70,
  batch_size = 10,
  validation_data = list(X_test, y_test),
  verbose = 1
)


model <- keras_model_sequential()
model %>%
  layer_lstm(units = 50, input_shape = c(sequence_length - 1, 1)) %>%
  layer_dense(units = 1)  # Output layer for regression task

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)


model <- keras_model_sequential() %>%
  bidirectional(layer_gru(units = 50, return_sequences = TRUE), input_shape = c(sequence_length - 1, 1)) %>%
  bidirectional(layer_gru(units = 50)) %>%
  layer_dense(units = 1)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

history <- model %>% fit(
  X_train, y_train,
  epochs = 10,
  batch_size = 32,
  validation_data = list(X_test, y_test),
  verbose = 1
)

evaluation <- model %>% evaluate(
  X_test, y_test,
  verbose = 0
)

save_model_hdf5(model, "simple_model.h5")

# Use the last 'sequence_length' data points as input for prediction
input_sequence <- tail(df, sequence_length - 1)

# Reshape the input sequence for prediction
input_sequence <- matrix(input_sequence, nrow = 1, ncol = sequence_length - 1)

# Perform prediction for the next data point
next_data_point <- model %>% predict(input_sequence)


input_sequence <- tail(df, sequence_length - 1)
input_sequence <- matrix(input_sequence, nrow = 1, ncol = sequence_length - 1)

# Perform prediction for the next 3 days
num_days_to_predict <- 3
predictions <- numeric(num_days_to_predict)

for (i in 1:num_days_to_predict) {
  next_data_point <- model %>% predict(input_sequence)
  predictions[i] <- next_data_point
  
  # Update the input sequence for the next prediction
  input_sequence <- array(append(input_sequence, next_data_point), dim = c(1, sequence_length - 1, ncol(df)))
  input_sequence <- input_sequence[, -1, ]  # Remove the first element to shift the sequence
}
