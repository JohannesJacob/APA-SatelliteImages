rm(list = ls())

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
validation_labels = c(rep(0,nfile(validation_directory,y="/einfach")),
                      rep(1,nfile(validation_directory,y="/gut")), 
                      rep(2,nfile(validation_directory,y="/mittel")))
train_samples <- length(train_labels)
validation_samples <- length(validation_labels)
batch_size <- 32
epochs <- 30

# Transfer Learning ------------------------------------------------------------

base_model <- application_resnet50(include_top = FALSE, weights = "imagenet")

# Loading images ---------------------------------------------------------------
train_generator <- flow_images_from_directory(directory = train_directory, 
                                               generator = image_data_generator(),
                                               #classes = c("gut", "einfach", "mittel"), 
                                               class_mode = "categorical",
                                               batch_size = batch_size,
                                               shuffle = F, 
                                               seed = 123)
train_generator$class_indices
validation_generator <- flow_images_from_directory(validation_directory, 
                                                    generator = image_data_generator(),
                                                    #classes = c("gut", "einfach", "mittel"), 
                                                    class_mode = "categorical",
                                                    shuffle = F,
                                                    batch_size = batch_size,
                                                    seed = 123)
validation_generator$class_indices

# Add custom fully connected layers --------------------------------------------

predictions <- base_model$output %>% 
  layer_global_average_pooling_2d(trainable = T) %>% 
  layer_dense(64, trainable = T) %>%
  layer_activation("relu", trainable = T) %>%
  layer_dropout(0.4, trainable = T) %>%
  layer_dense(3, trainable=T) %>%    ## important to adapt to fit the 3 classes in the dataset!
  layer_activation("softmax", trainable=T)

model <- keras_model(inputs = base_model$input, outputs = predictions)

# Freeze layers from base model ------------------------------------------------

for (layer in base_model$layers)
  layer$trainable <- FALSE

# Train the model --------------------------------------------------------------

model %>% compile(
                  loss = "categorical_crossentropy",
                  optimizer = optimizer_rmsprop(lr = 0.003, decay = 1e-6),  ## play with the learning rate
                  metrics = "accuracy"
                  )

hist <- model %>% 
        fit_generator(train_generator, 
                      steps_per_epoch = ceiling(train_samples/batch_size),
                      epochs = epochs, 
                      validation_data = validation_generator,
                      validation_steps = ceiling(validation_samples/batch_size),
                      verbose=2)

# save the model and its output ------------------------------------------------

save_model_weights_hdf5(model, 'models/bottleneck_resnet_v3_final.h5', overwrite = TRUE)
histDF <- data.frame(acc = unlist(hist$history$acc), 
                     val_acc = unlist(hist$history$val_acc), 
                     val_loss = unlist(hist$history$val_loss),
                     loss = unlist(hist$history$loss))

# at this point, the top layers are well trained and we can start fine-tuning
# convolutional layers from inception V3. We will freeze the bottom N layers
# and train the remaining top layers.

# let's visualize layer names and layer indices to see how many layers
# we should freeze:
layers <- base_model$layers
for (i in 1:length(layers))
  cat(i, layers[[i]]$name, "\n")

# we chose to train the top 2 inception blocks, i.e. we will freeze
# the first 172 layers and unfreeze the rest:
for (i in 1:172)
  layers[[i]]$trainable <- FALSE
for (i in 173:length(layers))
  layers[[i]]$trainable <- TRUE

# we need to recompile the model for these modifications to take effect
# we use SGD with a low learning rate
model %>% compile(
  optimizer = optimizer_sgd(lr = 0.0001, momentum = 0.9), 
  loss = 'categorical_crossentropy'
)

# we train our model again (this time fine-tuning the top 2 inception blocks
# alongside the top Dense layers
model %>% fit_generator(train_generator, 
                        steps_per_epoch = ceiling(train_samples/batch_size),
                        epochs = epochs, 
                        validation_data = validation_generator,
                        validation_steps = ceiling(validation_samples/batch_size),
                        verbose=2)



