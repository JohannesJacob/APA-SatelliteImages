# Scraping coordinates from the Immo data set

# read data
path <- "C:/Users/Johannes/Documents/APA-SatelliteImages/ImmoDaten/"

df <- read.csv(paste0(path, "ImmoBerlinCleaned.csv")) #, encoding = "UTF-8")

# reduce data set to only known streets

df_street <- df[df$Str!= "(missing)", ]

#put lineID
df_street$lineID <- seq(1, nrow(df_street), by = 1)

# apply further cleaning

# Strasse des 4. Juli hat flasche Hausnummern
df_street$StrNo <- as.factor(gsub("4. Juli ", "", df_street$StrNo))
df_street$StrNo <- as.factor(gsub("4 Juli ", "", df_street$StrNo))
df_street$StrNo <- as.factor(gsub("4 Jli ", "", df_street$StrNo))

# Eckhäuser nur durch eine Straße beschreiben
x <- which(nchar(as.character(df_street$StrNo))>10)
df_street$StrNo[x] <- substr(df_street$StrNo[x], 0, 2) 

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
  Sys.sleep(2)  # API only allows 5 requests per second
  out
}

# Loop to get functions CAREFUL: Google requests
df_street$lng <- NA
df_street$lat <- NA

for (i in 167:nrow(df_street)){
  tryCatch({
  request <- paste(df_street[i, "Str"], df_street[i, "StrNo"], df_street[i, "ZIP"], "Berlin")
  df_street[i,c("lng","lat")] <- t(geocodeAdddress(request))
  print(i)
  print(Sys.time())
  if(is.na(df_street$lat[i])) break
  }, error=function(e){})
}

View(df_street[,-c(5:196)])

write.csv(df_street, "Immo_streetCoordinates.csv", row.names = F, dec = ".")





