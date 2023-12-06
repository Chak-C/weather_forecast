library(dplyr)
library(MASS)
library(tensorflow)
library(keras)
library(caret)
library(nnet)

setwd('C:/DEV/Flutter-Weather/sample_data')

d <- read.csv('weather_data.csv')

d <- d %>% dplyr::select(date, value)

dates <- as.POSIXct(d$date, format = "%Y-%m-%dT%H:%M:%S")

# Convert datetime objects to numeric representation (timestamps)
timestamps <- as.numeric(dates)
d$time_scale <- (timestamps - min(timestamps)) / (max(timestamps) - min(timestamps))

temp <- ts(d$value/10)
plot(temp,type='b',main = 'average temp',
     xlab='year',ylab='temp?')
lines(lowess(time(temp),temp))

#modeling
df <- data.matrix(d %>% dplyr::select(value))
head(df)

lookback<- 40 #21 days of past data used in each current prediction
step <- 1 #observations sampled one data point per 3 days
delay <- 1 #Predict 1 day ahead

batch_size <- 15 #draw 20 samples at a time
predser <- 1 #Target is the 2nd series in the list, temperature

train_data <- df
mean <- mean(train_data[,1])
std <- sd(train_data[,1])
data <- scale(df[,1], center = mean, scale = std)

generator <- function(data, lookback, delay, min_index, max_index,
                      shuffle = FALSE, batch_size = 10, step = 1, predseries) {
  if (is.null(max_index)) max_index <- nrow(data) - delay - 1
  i <- min_index + lookback
  function() {
    if (shuffle) {
      rows <- sample(c((min_index+lookback):max_index), size = batch_size)
    } else {
      if (i + batch_size >= max_index)
        i <<- min_index + lookback
      rows <- c(i:min(i+batch_size, max_index))
      i <<- i + length(rows)
    }
    samples <- array(0, dim = c(length(rows),
                                lookback / step,
                                dim(data)[[-1]]))
    targets <- array(0, dim = c(length(rows)))
    for (j in 1:length(rows)) {
      indices <- seq(rows[[j]] - lookback, rows[[j]],
                     length.out = dim(samples)[[2]])
      samples[j,,] <- data[indices,]
      targets[[j]] <- data[rows[[j]] + delay,predseries]
    }
    list(samples, targets)
  }
}

train_gen <- generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 1,
  max_index = 1826,
  shuffle = TRUE,
  step = step,
  batch_size = batch_size,
  predseries = predser  
)

val_gen = generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 1827,
  max_index = 2185,
  step = step,
  batch_size = batch_size,
  predseries = predser  
)

test_gen <- generator(
  data,
  lookback = lookback,
  delay = delay,
  min_index = 1827,
  max_index = NULL,
  step = step,
  batch_size = batch_size,
  predseries = predser    
)

(1827 - 40) / 15
val_steps <- (365 - lookback) / batch_size
test_steps <- (nrow(df) - 1827 - lookback) / batch_size

##naive mnethod
evaluate_naive_method <- function() {
  batch_maes <- c()
  for (step in 1:val_steps) {
    c(samples, targets) %<-% val_gen()
    preds <- samples[,dim(samples)[[2]],1]
    mae <- mean(abs(preds - targets))
    batch_maes <- c(batch_maes, mae)
  }
  print(mean(batch_maes))
}
evaluate_naive_method()
temp <- evaluate_naive_method()
temp*std
# 0.32
# 1.3*C absolute error

## dense model (basic)
model <- keras_model_sequential() %>%
  layer_flatten(input_shape = c(lookback / step, dim(data)[-1])) %>%
  layer_dense(units = 32, activation = "relu") %>%
  layer_dense(units = 1)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)
history <- model %>% fit(
  train_gen,
  steps_per_epoch = 88,
  epochs = 10,
  validation_data = val_gen,
  validation_steps = val_steps
)
## 0.3669, 0.3318

## recurrent model
model <- keras_model_sequential() %>%
  layer_gru(units = 64, 
            input_shape = list(NULL, dim(data)[[-1]])) %>%
  layer_dense(units = 2)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)

history <- model %>% fit(
  train_gen,
  steps_per_epoch = 85,
  epochs = 10,
  validation_data = val_gen,
  validation_steps = val_steps
)

## dropout-regularized, stacked gru
model <- keras_model_sequential() %>%
  layer_gru(units = 64,
            dropout = 0.1,
            recurrent_dropout = 0.5,
            return_sequences = TRUE,
            input_shape = list(NULL, dim(data)[[-1]])) %>%
  layer_gru(units = 32, activation = "relu",
            dropout = 0.1,
            recurrent_dropout = 0.5) %>%
  layer_dense(units = 4)
model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)
history <- model %>% fit(
  train_gen,
  steps_per_epoch = 60,
  epochs = 10,
  validation_data = val_gen,
  validation_steps = val_steps
)

# bi-direction gru
model <- keras_model_sequential() %>%
  bidirectional(
    layer_gru(units = 32), input_shape = list(NULL, dim(data)[[-1]])
  ) %>%
  layer_dense(units = 1)
model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)
history <- model %>% fit(
  train_gen,
  steps_per_epoch = 110,
  epochs = 10,
  validation_data = val_gen,
  validation_steps = val_steps
)

# ltsm
model <- keras_model_sequential() %>%
  bidirectional(
    layer_gru(units = 32), input_shape = list(NULL, dim(data)[[-1]])
  ) %>%
  layer_gru(units = 64, activation = "relu",
            dropout = 0.1,
            recurrent_dropout = 0.5) %>%
  layer_dense(units = 1)
model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)
history <- model %>% fit(
  train_gen,
  steps_per_epoch = 72,
  epochs = 20,
  validation_data = val_gen,
  validation_steps = val_steps
)

# what is this
mdoel <-keras_model_sequential() %>%
  layer_conv_1d(filters=32, kernel_size=5, 
                kernel_regularizer = regularizer_l1(0.001), activation="sigmoid",
                input_shape = list(NULL, dim(data)[[-1]])) %>%
  layer_max_pooling_1d(pool_size=2) %>%
  layer_conv_1d(filters = 32, kernel_size = 5,
                kernel_regularizer = regularizer_l1(0.001),
                activation = "sigmoid") %>%
  layer_gru(units = 64, kernel_regularizer = regularizer_l1(0.001),
            dropout = 0.1, recurrent_dropout = 0.5) %>%
  layer_dense(units = 8)

model %>% compile(
  optimizer = optimizer_rmsprop(),
  loss = "mae"
)
history <- model %>% fit(
  train_gen,
  steps_per_epoch = 80,
  epochs = 10,
  validation_data = val_gen,
  validation_steps = val_steps
)

set.seed(15359)

densemodel <- keras_model_sequential() %>%
  layer_flatten(input_shape=c(lookback/step,dim(df)[-1])) %>%
  layer_dense(units=32,activation="relu") %>%
  layer_dense(units=1)


densemodel %>% compile(
  optimizer = "rmsprop",
  loss="acc"
)

(95 - 7) / 10
history <- densemodel %>% fit(
  train_gen,
  steps_per_epoch = 72,
  epochs = 20,
  validation_data = val_gen,
  validation_steps = val_steps
)

plot(history)
history

#recurrent network, single layer, 32 GRU, fit with RMSprop, by MSE
recmodel <- keras_model_sequential() %>%
  layer_gru(units = 32, dropout = 0.2, recurrent_dropout=0.2, input_shape = list(NULL, dim(df)[[-1]])) %>%
  layer_dense(units = 1)


recmodel %>% compile(
  optimizer = "rmsprop",
  loss="mae"
)

rechistory <- recmodel %>% fit(
  train_gen,
  steps_per_epoch = 70,
  epochs = 40,
  validation_data = val_gen,
  validation_steps = val_steps
)

rechistory
plot(rechistory)

rrmod <- keras_model_sequential() %>%
  layer_dense(units = 100, activation = "relu", input_shape = list(NULL, dim(df)[[-1]])) %>%
  #layer_batch_normalization() %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 50, activation = "relu", kernel_regularizer = regularizer_l2(0.001)) %>%
  layer_dropout(rate = 0.2) %>%
  layer_dense(units = 20, activation = "relu", kernel_regularizer = regularizer_l1(0.001)) %>%
  layer_dropout(rate = 0.1) %>%
  layer_dense(units = 1)

rrmod %>% compile(
  loss = "mse",
  optimizer = optimizer_adam(learning_rate = 0.002),
  metrics = "mae"
)

yeet <- rrmod %>% fit(
  train_gen,
  steps_per_epoch = 9,
  epochs = 35,
  validation_data = val_gen,
  validation_steps = val_steps
)

pred <- rrmod %>% predict(test_gen)
mse3 <- round(mean((pred-valY)^2),3)

model <- keras_model_sequential() %>%
  layer_dense(units = 64, activation = 'relu', input_shape = list(NULL, dim(df)[[-1]])) %>%
  layer_dense(units = 32, activation = 'relu') %>%
  layer_dense(units = 1)  # Output layer with 1 neuron for regression

# Compile the model
model %>% compile(
  optimizer = optimizer_adam(),  # You can experiment with different optimizers
  loss = 'mae'    # Using mean squared error for regression
)

# Train the model
history <- model %>% fit(
  train_gen,
  steps_per_epoch = 70,
  epochs = 20,
  batch_size = 32, 
  validation_data = val_gen,
  validation_steps = val_steps      # Splitting some data for validation
)

evaluation <- model %>% evaluate(
  test_gen,
  steps = test_steps  # Specify the number of steps (if required)
)

# Print the evaluation metrics
print(evaluation)
