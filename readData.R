# Prepare data for image extraction 

#libraries
library(dplyr)

# read data
path <- "C:/Users/Johannes/OneDrive/APA"

df <- read.csv(paste0(path, "/1. Data Sets/Immo_Daten/Berlin__Wohnlagen_2015.csv"), encoding = "UTF-8")

# data cleaning
df$WOL <- as.factor(df$WOL)
# drop 3 rows with missing value for WOL
df2 <- df[-(which(df$WOL == '')),]
# drop unused level
df2$WOL <- droplevels(df2$WOL)

# get exxact Coordinates
source("getCoordinates")
geocodeAdddress("Motzstr 10777 Berlin")

# group streets by no of unique values for WOL
smr <- summarise(group_by(df2, STRASSE), Nr_WOL = length(unique(WOL)))

