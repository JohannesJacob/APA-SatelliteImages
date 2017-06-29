# getting satelite image
library(ggmap)

mapImageData1 <- get_map(location = c(lon = 13.50132
                                      , lat = 52.52598),
                         color = "color",
                         source = "google",
                         maptype = "satellite",
                         zoom = 15
                         )

ggmap(mapImageData1,
      extent = "device",
      ylab = "Latitude",
      xlab = "Longitude")

#extract plot
m <- as.matrix(mapImageData1)

#check plot extraction
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
usr <- par("usr")
rasterImage(m, usr[1], usr[3], usr[2], usr[4])

# convert hex to rgb
col2gb()
