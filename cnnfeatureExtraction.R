# Extract feaures from penultimate layer
library(tensorflow)
library(keras)

# Immo images read-in setup
immo_directory <- "C:/Users/Johannes/Documents/ImmoImages"
immo_samples <- length(list.files(immo_directory))
batch_size <- 32

immo_generator <- flow_images_from_directory(immo_directory, 
                                            generator = image_data_generator(),
                                            classes = c("gut", "einfach", "mittel"), 
                                            class_mode = NULL,
                                            shuffle = F,
                                            batch_size = batch_size,
                                            seed = 123)

# load model last trainend model
model_vgg <- application_vgg16(include_top = FALSE, weights = "imagenet",
                               input_shape = as.integer(c(256, 256, 3)))

top_model <- keras_model_sequential()
top_model %>%
  layer_dense(units=9647,input_shape = (model_vgg$output_shape[2:4])) %>% 
  layer_flatten() %>%
  layer_dense(256) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(3) %>%
  layer_activation("softmax")
load_model_weights_hdf5(top_model, "models/bottleneck_30_epochsR_IT.h5")

# define layer that should be the output
summary(top_model)
layer_name <- 'activation_7'
intermediate_layer_model <- keras_model(inputs=top_model$input,
                                 outputs= top_model$get_layer(layer_name)$output)

# predict with the adjusted model 
penultimate_output <- predict_generator(top_model,
                                        immo_generator,
                                        ceiling(immo_samples / batch_size),
                                        verbose = 1 )

##Testing
test_result <- predict_generator(model_vgg,
                                 immo_generator, 
                                ceiling(immo_samples / batch_size),
                                verbose = 1       )

