# getting satelite image
library(ggmap)
library (png)
library(ggplot2)

#put lineID
streetOnly$lineID <- seq(1, nrow(streetOnly), by = 1)

#for loop
for (i in 12064:12207) {
  longitude     <- streetOnly$lng[i]
  latitude      <- streetOnly$lat[i]
  
  if (is.na(latitude)) next
    
  mapImageData1 <- get_map(location = c(lon = longitude, lat = latitude),
                           color    = "color",
                           source   = "google",
                           maptype  = "satellite",
                           zoom     = 15)
  
  ggsave(paste0("C:/Users/Johannes/Documents/SatelliteImages/Bild_", as.character(i),".png"),
         ggmap(mapImageData1, 
               extent = "device", 
               ylab = "Latitude", 
               xlab = "Longitude"))
  
  print(i)
  print(Sys.time())
  
}  



#extract plot
m <- as.matrix(mapImageData1)

# convert hex to rgb
c <- col2rgb(m)

# save image
writePNG(c, target = "C:/Users/Johannes/Documents/SatelliteImages/Bild_test.png")


r <- writePNG(c)

#check plot extraction

ggmap(mapImageData1,
      extent = "device",
      ylab = "Latitude",
      xlab = "Longitude")

plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
usr <- par("usr")
rasterImage(m, usr[1], usr[3], usr[2], usr[4])

