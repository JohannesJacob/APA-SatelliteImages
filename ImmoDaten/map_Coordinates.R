# Mapping coordinates

library(ggmap)
mygggmap <- get_map(location = "Berlin", zoom = 11)
g <- ggmap(mygggmap)

g <- g + geom_point(data = df_street_noNA, aes(x = lng, y = lat))

g
