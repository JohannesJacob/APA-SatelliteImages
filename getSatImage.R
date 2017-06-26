# getting satelite image
library(ggmap)

mapImageData1 <- get_map(location = c(lon = 13.50132
                                      , lat = 52.52598),
                         color = "color",
                         source = "google",
                         maptype = "satellite",
                         zoom = 21
                         )

ggmap(mapImageData1,
      extent = "device",
      ylab = "Latitude",
      xlab = "Longitude")


