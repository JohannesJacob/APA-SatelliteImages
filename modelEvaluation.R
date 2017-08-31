# model evaluation

rm(list = ls())
print(paste("Run started:", Sys.time(), sep = " "))

# Load packages ----------------------------------------------------------------
packages <- c("caret", "doParallel", "randomForest", "nnet", "foreach")

sapply(packages, require, character.only = TRUE)

# Loading data -----------------------------------------------------------------

# 1. DF: HA + POI
df_immo <- read.csv("Immo_fix.csv")
df_immo <- df_immo[,-1]

# 2. DF: HA (House Attributes)
df_immo_HA <- df_immo[, 1:75]

# 3. DF: POI
df_immo_POI <- df_immo[, c(1, 76:ncol(df_immo))]

# Loading feature extraction matrix
features <- readRDS("models/penultimate_pred_256.rds")
features <- features[-119,] #outlier removed

# 4. DF: Feature matrix and price
features_immoprice <- as.data.frame(cbind(price = df_immo$price, features))

# 5. DF: HA + Feature matrix
df_immo_HA_features   <- cbind(df_immo_HA, features)

# 6. DF: HA + POI + Feature matrix
df_immo_features   <- cbind(df_immo, features)


# Prepare the model training process -------------------------------------------

#Use parallel computing
nrOfCores  <- detectCores()-1
registerDoParallel(cores = nrOfCores)
message(paste("\n Registered number of cores:\n",nrOfCores,"\n"))

#Select subset for training and testing
set.seed(123)      

inTrain    <- createDataPartition(y = df_immo_features$price, p = 0.8, list = FALSE) #change DF name!!!
training   <- df_immo_features[inTrain,]#change DF name!!!
testing    <- df_immo_features[-inTrain,]#change DF name!!!

#Setting up a 10-fold repeated cross validation

#set trainControl for caret
model.control <- trainControl(
  method = "repeatedcv",
  number = 10,
  repeats = 3,
  allowParallel = TRUE,
  returnData = FALSE #FALSE, to reduce straining memomry 
)

# Training of models -----------------------------------------------------------

# OLS training 
lm_model <- train(form = price~., 
                  data = training,  
                  method    = "lm", 
                  trControl = model.control)

# RF training
param.rf <- expand.grid(mtry = seq(5, 15, by = 5))
rf_model <- train(form = price~., 
                  data = training,  
                  method    = "rf",
                  grid      = param.rf,
                  trControl = model.control)

# Single layer perceptron (SLP) training 
param.nnet <- expand.grid(decay = seq(0.5, 1.5, by =  0.5),
                          size = seq(10, 30, by = 10))
nent_model <- train(form = price~., 
                  data = training,  
                  method    = "nnet",
                  grid      = param.nnet,
                  trControl = model.control,
                  linout    = FALSE,
                  maxit     = 100,
                  trace     = FALSE)



# Testing models ---------------------------------------------------------------

# lm prediction
lm_pred <- predict(lm_model,
                   newdata = testing,
                   type = "raw")

# rf prediction
rf_pred <- predict(rf_model,
                   newdata = testing,
                   type = "raw")

# nnet prediction
rf_pred <- predict(nnet_model,
                   newdata = testing,
                   type = "raw")

# Assessment of models ---------------------------------------------------------

# variable importance
varImp(lm_model)
varImp(rf_model)
varImp(nnet_model)

# summary of performance
modelvalues_lm<-data.frame(obs = testing$price, pred=lm_pred)
defaultSummary(modelvalues_lm)
modelvalues_rf<-data.frame(obs = testing$price, pred=rf_pred)
defaultSummary(modelvalues_rf)
modelvalues_nnet<-data.frame(obs = testing$price, pred=nnet_pred)
defaultSummary(modelvalues_nnet)

