# Using transfer Learning

# Loading Tensorflow and Keras -------------------------------------------------
library(tensorflow)
library(keras)

# File locations and settings --------------------------------------------------
## TEST directory
train_directory <- "C:/Users/Johannes/Documents/TestImages/train"
validation_directory <- "C:/Users/Johannes/Documents/TestImages/validation"
train_samples <- 9647
validation_samples <- 2404
batch_size <- 32
epochs <- 30

# Transfer Learning ------------------------------------------------------------

model_vgg <- application_vgg16(include_top = FALSE, weights = "imagenet")

# Loading images ---------------------------------------------------------------
train_generator_bottleneck <- flow_images_from_directory(directory = train_directory, 
                                              generator = image_data_generator(),
                                              classes = c("gut", "einfach", "mittel"), 
                                              batch_size = batch_size,
                                              shuffle = F, 
                                              seed = 123)
validation_generator_bottleneck <- flow_images_from_directory(validation_directory, 
                                                   generator = image_data_generator(),
                                                   classes = c("gut", "einfach", "mittel"), 
                                                   shuffle = F,
                                                   batch_size = batch_size,
                                                   seed = 123)

# Saving output of transfer learning model -------------------------------------

bottleneck_features_train <- predict_generator(model_vgg,train_generator_bottleneck, 
                                               train_samples / batch_size)
saveRDS(bottleneck_features_train, "models/bottleneck_features_train.rds") #check SAVInG location
bottleneck_features_validation <- predict_generator(model_vgg,
                                                    validation_generator_bottleneck, 
                                                    validation_samples / batch_size)
saveRDS(bottleneck_features_validation, "models/bottleneck_features_validation.rds")

# Loading saved transfer learning output ---------------------------------------

bottleneck_features_train <- readRDS("models/bottleneck_features_train.rds")
bottleneck_features_validation <- readRDS("models/bottleneck_features_validation.rds")
train_labels = c(rep(0,train_samples/3),rep(1,train_samples/3), rep(2,train_samples/3))
validation_labels = c(rep(0,train_samples/3),rep(1,train_samples/3), rep(2,train_samples/3))

# Define custom fully connected layer ------------------------------------------

model_top <- keras_model_sequential()
model_top %>%
  layer_dense(units=nrow(bottleneck_features_train),input_shape = dim(bottleneck_features_train)[2:4]) %>% 
  layer_flatten() %>%
  layer_dense(256) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(3) %>%
  layer_activation("sigmoid")
model_top %>% compile(
  loss = "categorical_crossentropy",
  optimizer = optimizer_rmsprop(lr = 0.0001, decay = 1e-6),
  metrics = "accuracy")


