# getting satelite image
library(ggmap)

mapImageData1 <- get_map(location = c(lon = 34.93809275, lat = -9.85632177),
                         color = "color",
                         source = "google",
                         maptype = "satellite",
                         zoom = 16
                         )

ggmap(mapImageData1,
      extent = "device",
      ylab = "Latitude",
      xlab = "Longitude")


