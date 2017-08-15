# Using transfer Learning

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

bottleneck_features_train <- predict_generator(model_vgg,
                                               train_generator_bottleneck, 1)
                                               #train_samples / batch_size)
saveRDS(bottleneck_features_train, "models/bottleneck_features_train.rds") #check SAVInG location
bottleneck_features_validation <- predict_generator(model_vgg,
                                                    validation_generator_bottleneck, 1) 
                                                    #validation_samples / batch_size)
saveRDS(bottleneck_features_validation, "models/bottleneck_features_validation.rds")

# Loading saved transfer learning output ---------------------------------------

bottleneck_features_train <- readRDS("models/bottleneck_features_train.rds")
bottleneck_features_validation <- readRDS("models/bottleneck_features_validation.rds")

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

# Training ---------------------------------------------------------------------

valid = list(bottleneck_features_validation, validation_labels)
model_top %>% fit(
  x = bottleneck_features_train, y = train_labels,
  epochs=epochs, 
  batch_size=16,  ##Hit out of memory with a batch size of 32
  validation_data=valid,
  verbose=2)

save_model_weights_hdf5(model_top, 'models/bottleneck_30_epochsR.h5', overwrite = TRUE)

# Validation -------------------------------------------------------------------

evaluate(model_top,bottleneck_features_validation, validation_labels)


