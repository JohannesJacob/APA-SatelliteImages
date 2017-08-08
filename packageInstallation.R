# Installing Keras and Tensorflow at the backend

#You need to install Rtools for installing ‘reticulate’ package for using the above packahes in R. 
#The reticulate package provides an R interface to Python modules, classes, and functions
#You can install Rtools for your R version here — 
#https://cran.r-project.org/bin/windows/Rtools/
#installing 'devtools' package for installing Packages from github
install.packages('devtools')
#installing keras
devtools::install_github("rstudio/keras") 

library(keras)

#The R interface to Keras uses TensorFlow as it’s underlying #computation engine.
#So we need to install Tensorflow engine

install_tensorflow() #does all computation at the backend on the cpu
#For installing the GPU version of tensorflow: https://tensorflow.rstudio.com/installation_gpu.html
#install_tensorflow(gpu = T)




