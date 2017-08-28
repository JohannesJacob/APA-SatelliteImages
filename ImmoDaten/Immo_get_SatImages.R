# Scraping satellite images from the Immo data set

library(ggmap)
library (png)
library(ggplot2)

df_street <- read.csv("Immo_streetCoordinates.csv")


# Loop through the images by line ## Check if any NA in long/lat
for (i in 1:nrow(df_street)) {
  longitude     <- df_street$lng[i]
  latitude      <- df_street$lat[i]
  
  if (is.na(latitude)) next
  
  mapImageData1 <- get_map(location = c(lon = longitude, lat = latitude),
                           color    = "color",
                           source   = "google",
                           maptype  = "satellite",
                           zoom     = 15)
  
  ggsave(paste0("C:/Users/Johannes/Documents/ImmoImages/Bild_", as.character(i),".png"),
         ggmap(mapImageData1, 
               extent = "device", 
               ylab = "Latitude", 
               xlab = "Longitude"))
  
  print(i)
  print(Sys.time())
  
}  
