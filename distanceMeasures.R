# new approach using delaunay and kNN to derive W

df_street <- read.csv("Immo_streetCoordinates.csv")
df_street_noNA <- df_street[complete.cases(df_street),]

# Convert data frame to a spatial object
library(sp)
spdf_street <- SpatialPointsDataFrame(coords = df_street_noNA[, c("lng", "lat")],
                                      proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"),
                                      data = df_street_noNA)

coords <- coordinates(spdf_street)

# Creating Graph based neighbours
IDs <- row.names(as(spdf_street, "data.frame"))
street_nb <- dnearneigh(coords, row.names = IDs)
if (require(rgeos, quietly = TRUE) && require(RANN, quietly = TRUE)) {
  Sy5_nb <- graph2nb(soi.graph(Sy4_nb, coords), row.names = IDs)
  } else Sy5_nb <- NULL
Sy6_nb <- graph2nb(gabrielneigh(coords, nnmult = 9), row.names = IDs)
Sy7_nb <- graph2nb(relativeneigh(coords, nnmult = 9), row.names = IDs)

# Distance-based neighbours
Sy8_nb <- knn2nb(knearneigh(coords, k = 1), row.names = IDs)
Sy9_nb <- knn2nb(knearneigh(coords, k = 2), row.names = IDs)
Sy10_nb <- knn2nb(knearneigh(coords, k = 4), row.names = IDs)
nb_l <- list(k1 = Sy8_nb, k2 = Sy9_nb, k4 = Sy10_nb)
sapply(nb_l, function(x) is.symmetric.nb(x, verbose = FALSE, force = TRUE))
sapply(nb_l, function(x) n.comp.nb(x)$nc)

# using k01 to find the distance at which all areas have a distance based neighbour
dsts <- unlist(nbdists(Sy8_nb, coords))
max_1nn <- max(dsts) # minimum distance at which all are connected
max_1nn

# calculating the inter-point distance
Sy11_nb <- dnearneigh(coords, d1 = 0, d2 = 0.75 * max_1nn, row.names = IDs)
Sy12_nb <- dnearneigh(coords, d1 = 0, d2 = 1 * max_1nn, row.names = IDs)
Sy13_nb <- dnearneigh(coords, d1 = 0, d2 = 1.5 * max_1nn, row.names = IDs)
nb_l <- list(d1 = Sy11_nb, d2 = Sy12_nb, d3 = Sy13_nb)
sapply(nb_l, function(x) is.symmetric.nb(x, verbose = FALSE, force = TRUE))
sapply(nb_l, function(x) n.comp.nb(x)$nc)
dsts0 <- unlist(nbdists(NY_nb, coordinates(NY8)))
summary(dsts0)


