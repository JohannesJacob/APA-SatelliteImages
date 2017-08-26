# Scraping coordinates from the Immo data set

# read data
path <- "C:/Users/Johannes/Documents/APA-SatelliteImages/ImmoDaten/"

df <- read.csv(paste0(path, "ImmoBerlinCleaned.csv")) #, encoding = "UTF-8")

# reduce data set to only known streets

df_street <- df[df$Str!= "(missing)", ]

# checken wie google Eck daten liest !!!
# checken wie wir am besten doppelte Adressen händeln: unique_streets <- unique(df[, c("Str","StrNo")])

# Function: get Coordinates from Street Address

geocodeAdddress <- function(address) {
  require(RJSONIO)
  url <- "https://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url, address, "&key=AIzaSyB8FFsYpfZgTz4mHVaSBHyB2y8l9HBKIb8", sep = ""))
  #embedding API: https://stackoverflow.com/questions/34402979/increase-the-api-limit-in-ggmaps-geocode-function-in-r
  x <- fromJSON(url, simplify = FALSE)
  if (x$status == "OK") {
    out <- c(x$results[[1]]$geometry$location$lng,
             x$results[[1]]$geometry$location$lat)
  } else {
    out <- NA
  }
  Sys.sleep(0.2)  # API only allows 5 requests per second
  out
}

# Loop to get functions CAREFUL: Google requests
df_street$lng <- NA
df_street$lat <- NA

for (i in 1:nrow(df_street)){
  request <- paste(df_street[i, "Str"], df_street[i, "StrNo"], df_street[i, "ZIP"], "Berlin")
  df_street[i,c("lng","lat")] <- t(geocodeAdddress(request))
}

write.csv(df_street, "Immo_streetCoordinates.csv", row.names = F, dec = ".")





