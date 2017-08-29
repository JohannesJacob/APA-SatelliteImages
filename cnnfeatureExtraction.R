# Extract feaures from penultimate layer
library(tensorflow)
library(keras)

# Immo images read-in setup
immo_directory <- "C:/Users/Johannes/Documents/ImmoImages"
immo_samples <- length(list.files(paste0(immo_directory, "/unknown")))
batch_size <- 32

immo_generator <- flow_images_from_directory(immo_directory, 
                                            generator = image_data_generator(),
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
#model_ft <- keras_model(inputs = model_vgg$input, outputs = top_model(model_vgg$output))

# define layer that should be the output
summary(top_model)
layer_name <- 'activation_9' # always has to be changed. see summary
intermediate_layer_model <- keras_model(inputs=top_model$input,
                                 outputs= top_model$get_layer(layer_name)$output)

# predict with the adjusted model 
vgg_output <- predict_generator(model_vgg,
                                immo_generator,
                                ceiling(immo_samples / batch_size),
                                verbose = 1 )

penultimate_output <- predict(intermediate_layer_model,
                              vgg_output)

saveRDS(vgg_output, "models/vgg_pred_256.rds")
saveRDS(penultimate_output, "models/penultimate_pred_256.rds")

