# get Satellite images (see for documentation: https://github.com/amsantac/SkyWatchr)

library(SkyWatchr)

#set API key
api_key <- "abddf820-5245-414b-87de-6b4e4308a3b2"

#set global options
options(SkyWatchr.apikey = api_key)

# Query image
ex1 <- data.frame(x = -71.1043443253, y = -42.3150676016, data = "point")
coordinates(ex1) <- ~ x + y
class(ex1)
querySW(time_period = "2015-8", longitude_latitude = ex1)

