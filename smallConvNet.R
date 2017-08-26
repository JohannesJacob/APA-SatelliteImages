# Small Conv net

# Loading Tensorflow and Keras -------------------------------------------------
library(tensorflow)
library(keras)

# File locations and settings --------------------------------------------------
## TEST directory
train_directory <- "C:/Users/Johannes/Documents/TestImages/train"
validation_directory <- "C:/Users/Johannes/Documents/TestImages/validation"
nfile <- function(path = train_directory, y) {length(list.files(paste0(path,y)))}
train_labels = c(rep(0,nfile(y="/einfach")),
                 rep(1,nfile(y="/gut")), 
                 rep(2,nfile(y="/mittel")))
validation_labels = c(rep(0,nfile(validation_directory,y="/einfach")),
                      rep(1,nfile(validation_directory,y="/gut")), 
                      rep(2,nfile(validation_directory,y="/mittel")))
train_samples <- length(train_labels)
validation_samples <- length(validation_labels)
batch_size <- 32
epochs <- 30

#Loading images ----------------------------------------------------------------
train_generator <- flow_images_from_directory(directory = train_directory, 
                                              generator = image_data_generator(),
                                              classes = c("gut", "einfach", "mittel"), 
                                              batch_size = batch_size,
                                              shuffle = T, 
                                              seed = 123)
validation_generator <- flow_images_from_directory(validation_directory, 
                                                   generator = image_data_generator(),
                                                   classes = c("gut", "einfach", "mittel"), 
                                                   shuffle = T,
                                                   batch_size = batch_size,
                                                   seed = 123)

# Model architecture definition ------------------------------------------------

model <- keras_model_sequential()
model %>%
  layer_conv_2d(filter = 32, kernel_size = c(3,3), input_shape = c(256, 256, 3)) %>%
  layer_activation("relu") %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>% 
  
  layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
  layer_activation("relu") %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  
  layer_conv_2d(filter = 64, kernel_size = c(3,3)) %>%
  layer_activation("relu") %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  
  layer_flatten() %>%
  layer_dense(64) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(3) %>%
  layer_activation("softmax")
model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = optimizer_rmsprop(lr = 0.0001, decay = 1e-6),
  metrics = "accuracy"
)

# Training ---------------------------------------------------------------------

model %>% fit_generator(
  train_generator,
  steps_per_epoch = ceiling(train_samples/batch_size), 
  epochs = epochs, 
  validation_data = validation_generator,
  validation_steps = ceiling(validation_samples/batch_size),
  verbose=2
)

save_model_weights_hdf5(model, 'models/basic_cnn_30_epochsR.h5', overwrite = TRUE)

# Validation -------------------------------------------------------------------

evaluate_generator(model,validation_generator, validation_samples)

