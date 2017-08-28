# Using transfer Learning 

##image size default 256, 256, 3

# Loading Tensorflow and Keras -------------------------------------------------
library(tensorflow)
library(keras)

# File locations and settings --------------------------------------------------
## TEST directory
train_directory <- "C:/Users/Johannes/Documents/SatelliteImages/train"
validation_directory <- "C:/Users/Johannes/Documents/SatelliteImages/validation"
nfile <- function(path = train_directory, y) {length(list.files(paste0(path,y)))}
train_labels = c(rep(0,nfile(y="/einfach")),
                 rep(1,nfile(y="/gut")), 
                 rep(2,nfile(y="/mittel")))
train_samples <- length(train_labels)
train_labels <- to_categorical(train_labels)
validation_labels = c(rep(0,nfile(validation_directory,y="/einfach")),
                      rep(1,nfile(validation_directory,y="/gut")), 
                      rep(2,nfile(validation_directory,y="/mittel")))
validation_samples <- length(validation_labels)
validation_labels <- to_categorical(validation_labels)
batch_size <- 32
epochs <- 30

# Transfer Learning ------------------------------------------------------------

model_vgg <- application_vgg16(include_top = FALSE, weights = "imagenet") # can be changed to resnset 

# Loading images ---------------------------------------------------------------
train_generator_bottleneck <- flow_images_from_directory(directory = train_directory, 
                                              generator = image_data_generator(),
                                              #classes = c("gut", "einfach", "mittel"), 
                                              class_mode = NULL,
                                              batch_size = batch_size,
                                              shuffle = F, 
                                              seed = 123)
train_generator_bottleneck$class_indices
validation_generator_bottleneck <- flow_images_from_directory(validation_directory, 
                                                   generator = image_data_generator(),
                                                   #classes = c("gut", "einfach", "mittel"), 
                                                   class_mode = NULL,
                                                   shuffle = F,
                                                   batch_size = batch_size,
                                                   seed = 123)
validation_generator_bottleneck$class_indices

# Saving output of transfer learning model -------------------------------------

#SKIP TO NEXT SECTION IF PREDICTION ALREADY DONE ONCE 
#CHANGE NAME AND DELETE "_test"
bottleneck_features_train <- predict_generator(model_vgg,
                                               train_generator_bottleneck, 
                                               ceiling(train_samples / batch_size),
                                               verbose = 1       ) #Important to say ceiling!!!
saveRDS(bottleneck_features_train, "models/bottleneck_features_train_B.rds") 
bottleneck_features_validation <- predict_generator(model_vgg,
                                                    validation_generator_bottleneck, 
                                                    ceiling(validation_samples / batch_size),
                                                    verbose = 1  )
saveRDS(bottleneck_features_validation, "models/bottleneck_features_validation_B.rds")

# Loading saved transfer learning output ---------------------------------------

bottleneck_features_train <- readRDS("models/bottleneck_features_train.rds")
bottleneck_features_validation <- readRDS("models/bottleneck_features_validation.rds")

# Define custom fully connected layer ------------------------------------------

model_top <- keras_model_sequential()
model_top %>%
  layer_dense(units=nrow(bottleneck_features_train),input_shape = dim(bottleneck_features_train)[2:4]) %>% #try starting with layer flatten
  layer_flatten() %>%
  layer_dense(256) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(3) %>%
  layer_activation("softmax")
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

# Fine Tuning the model ########################################################

# Model setup ------------------------------------------------------------------

model_vgg <- application_vgg16(include_top = FALSE, weights = "imagenet",
                               input_shape = as.integer(c(256, 256, 3)))

top_model <- keras_model_sequential()
top_model %>%
  layer_dense(units=nrow(bottleneck_features_train),input_shape = (model_vgg$output_shape[2:4])) %>% 
  layer_flatten() %>%
  layer_dense(256) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(3) %>%
  layer_activation("softmax")
load_model_weights_hdf5(top_model, "models/bottleneck_30_epochsR_IT.h5")
model_ft <- keras_model(inputs = model_vgg$input, outputs = top_model(model_vgg$output))

# Only training of a few layers ------------------------------------------------

for (layer in model_ft$layers[1:16]) # First 16 layers are non-trainable
  layer$trainable <- FALSE

# Compile with SGD/ momentum optimizer and slow learning rate ------------------

model_ft %>% compile(
  loss = "categorical_crossentropy",
  optimizer = optimizer_sgd(lr=1e-3, momentum=0.9),
  metrics = "accuracy")

# Augmentation and generator setup ---------------------------------------------

augment <- image_data_generator(rescale=1./255,
                                shear_range=0.2,
                                zoom_range=0.2,
                                horizontal_flip=TRUE)
train_generator_augmented <- flow_images_from_directory(train_directory, 
                                                        generator = augment,
                                                        color_mode = "rgb",
                                                        class_mode = "categorical",
                                                        batch_size = batch_size, 
                                                        shuffle = TRUE,
                                                        seed = 123)

validation_generator <- flow_images_from_directory(validation_directory, 
                                                   generator = image_data_generator(rescale=1./255),
                                                   color_mode = "rgb", 
                                                   classes = NULL,
                                                   class_mode = "categorical", 
                                                   batch_size = batch_size, 
                                                   shuffle = TRUE,
                                                   seed = 123)

# Fine-tune model --------------------------------------------------------------

model_ft %>% fit_generator(
  train_generator_augmented,
  steps_per_epoch = ceiling(train_samples/batch_size), 
  epochs = epochs, 
  validation_data = validation_generator,
  validation_steps = ceiling(validation_samples/batch_size),
  verbose=2
)

save_model_weights_hdf5(model_ft, 'finetuning_30epochs_vggR.h5', overwrite = TRUE)

# Evaluating on validation set -------------------------------------------------

evaluate_generator(model_ft,validation_generator, validation_samples)


