# CNN setup: http://htmlpreview.github.io/?https://github.com/rajshah4/image_keras/blob/master/Rnotebook.nb.html

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
                           shuffle = F,
                           seed = 123)
validation_generator <- flow_images_from_directory(validation_directory, 
                           generator = image_data_generator(),
                           classes = c("gut", "einfach", "mittel"), 
                           shuffle = F,
                           seed = 123)

# Model architecture definition ------------------------------------------------

#model set up with transfer learning from Microsoft
base_model <- application_resnet50(include_top = F, weights = "imagenet")

# add our custom layers
predictions <- base_model$output %>% 
  layer_global_average_pooling_2d() %>% 
  layer_dense(units = 1024, activation = 'relu') %>% 
  layer_dense(units = 3, activation = 'softmax')

# this is the model we will train
model <- keras_model(inputs = base_model$input, outputs = predictions)

# first: train only the top layers (which were randomly initialized)
# i.e. freeze all convolutional InceptionV3 layers
for (layer in base_model$layers)
  layer$trainable <- FALSE

# compile the model (should be done *after* setting layers to non-trainable)
model %>% compile(optimizer = 'rmsprop', loss = 'categorical_crossentropy')

# Training ---------------------------------------------------------------------

# train the model on the new data for a few epochs
model %>% fit_generator(train_generator, 
                        steps_per_epoch = ceiling(train_samples/batch_size),
                        epochs = epochs, 
                        validation_data = validation_generator,
                        validation_steps = ceiling(validation_samples/batch_size),
                        verbose=2)

# at this point, the top layers are well trained and we can start fine-tuning
# convolutional layers from ResNet. We will freeze the bottom N layers
# and train the remaining top layers.

# let's visualize layer names and layer indices to see how many layers
# we should freeze:
layers <- base_model$layers
for (i in 1:length(layers))
  cat(i, layers[[i]]$name, "\n")

# we chose to train the top 2 blocks, i.e. we will freeze
# the first 152 layers and unfreeze the rest:
for (i in 1:152)
  layers[[i]]$trainable <- FALSE
for (i in 153:length(layers))
  layers[[i]]$trainable <- TRUE

# we need to recompile the model for these modifications to take effect
# we use SGD with a low learning rate
model %>% compile(
  optimizer = optimizer_sgd(lr = 0.0001, momentum = 0.9), 
  loss = 'categorical_crossentropy'
)

# we train our model again (this time fine-tuning the top 2 inception blocks
# alongside the top Dense layers
history <- model %>% fit_generator(train_generator, 
                                   steps_per_epoch = ceiling(train_samples/batch_size),
                                   epochs = epochs, 
                                   validation_data = validation_generator,
                                   validation_steps = ceiling(validation_samples/batch_size),
                                   verbose=2)


# Saving the model results
save_model_weights_hdf5(model, "finetuning_1epoch_ResNet.h5", overwrite = T)

# Testing ----------------------------------------------------------------------

# Evaluating on validation set 
res <- evaluate_generator(model,validation_generator, validation_samples) # validation sample in test =34






