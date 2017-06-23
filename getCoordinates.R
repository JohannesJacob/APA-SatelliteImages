# get Sreet Adress
streetOnly <- summarise(group_by(df, STRASSE, PLZ, WOL))
streetOnly <- streetOnly[-1,]

# Function: get Coordinates from Street Address

geocodeAdddress <- function(address) {
  require(RJSONIO)
  url <- "http://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url, address, "&sensor=false", sep = ""))
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
streetOnly$lng <- NA
streetOnly$lat <- NA

for (i in 1:nrow(streetOnly)){
  request <- paste(streetOnly[i, 1], streetOnly[i, 2], "Berlin")
  streetOnly[i,c("lng","lat")] <- t(geocodeAdddress(request))
}


