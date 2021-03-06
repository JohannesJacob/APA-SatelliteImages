# SAR benchmark code mit lagsarlm function
library(spdep)

df_street_noNA <- read.csv("Immo_preProcessed.csv")
df_street_noNA <- df_street_noNA[,-1]

# Convert data frame to a spatial object
spdf_street <- SpatialPointsDataFrame(coords = df_street_noNA[, c("lng", "lat")],
                                      proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"),
                                      data = df_street_noNA)
coords <- coordinates(spdf_street)

# get distance matrix
IDs <- row.names(as(spdf_street, "data.frame"))
Sy8_nb <- knn2nb(knearneigh(coords, k = 1), row.names = IDs)
dsts <- unlist(nbdists(Sy8_nb, coords))
max_1nn <- max(dsts)

nb.1.5 <- dnearneigh(coords, d1 = 0, d2 = 1.5 * max_1nn, row.names = IDs)
knn.10 <- knearneigh(coords, k = 10)
knn.10 <- knn2nb(knn.10, row.names = IDs)

# plotting results
plot(nb2listw(knn.10, style="W"), coords)

# calculate matrix
#COL.lag.eig <- lagsarlm(price ~.,
#                        data=df_street_noNA[, -c(1:5,81,92,118:121,128,130,134,137:140,143,146,149,152,155:158,
#                                                 126, 162,165,168,171,174,177:180,186,189,192:199)],
#                        nb2listw(knn.10, style="W"), method="eigen", quiet=FALSE)
#summary(COL.lag.eig, correlation=TRUE)


# df without multi-collinaer variables
df_fix <- df_street_noNA[, -c(1:5,81,92,118:121,128,130,134,137:140,143,146,149,152,155:158,
                              126, 162,165,168,171,174,177:180,186,189,192:199)]
write.csv(df_fix, "Immo_fix.csv")

# model definition

#simple ols
lm_model <- lm(price ~.,
               data=df_fix)

#SAR model
spdf_sar <- lagsarlm(price ~.,
                    data=df_fix,
                    nb2listw(knn.10, style="W"), tol = 1.0e-30)
summary(spdf_sar)
summary.sarlm(spdf_sar, Nagelkerke = T) # Spatial Lag is significant and some of the features

# Checking whether we have auto-correlation
moran.mc(summary(spdf_sar)$residuals, nb2listw(knn.10, style="W"), 999)
# Yes, we have autocorrelation with a significance at the 1% level

# Save the model
saveRDS(spdf_sar, "models/sar_knn10.rds")
saveRDS(spdf_sar, "models/sar_delauney.rds")
saveRDS(lm_model, "models/simple_ols.rds")

