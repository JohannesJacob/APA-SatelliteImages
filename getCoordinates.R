# get Sreet Adress
streetOnly <- df2 %>% 
                  group_by(STRASSE, PLZ, WOL)%>%
                  summarise(NMBR = round(median(ADR_noletters, na.rm = T))) %>% 
                  as.data.frame()

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
streetOnly$lng <- NA
streetOnly$lat <- NA

for (i in 10001:12207){
  request <- paste(streetOnly[i, 1], streetOnly[i, 4], streetOnly[i, 2], "Berlin")
  streetOnly[i,c("lng","lat")] <- t(geocodeAdddress(request))
}

write.csv(streetOnly, "streetCoordinates.csv", row.names = F, dec = ".")
