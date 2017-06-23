# Prepare data for image extraction 

# read data
path <- "C:/Users/Benjamin/OneDrive/APA"

df <- read.csv(paste0(path, "/1. Data Sets/Immo_Daten/Berlin__Wohnlagen_2015.csv"), stringsAsFactors = F, encoding = "UTF-8")

# data cleaning
#gsub zum Städtenamen ändern

# get exxact Coordinates
source("getCoordinates")
geocodeAdddress("Motzstr 10777 Berlin")

