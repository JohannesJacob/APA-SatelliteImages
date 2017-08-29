# Spatial Auto-Regression on Immo-Data
library(HSAR)

df_street <- read.csv("Immo_streetCoordinates.csv")
df_street_noNA <- df_street[complete.cases(df_street),]

# Convert data frame to a spatial object
library(sp)
spdf_street <- SpatialPointsDataFrame(coords = df_street_noNA[, c("lng", "lat")],
                                      proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"),
                                      data = df_street_noNA)

coords <- coordinates(spdf_street)

# extract the land parcel level spatial weights matrix
library(spdep)
nb.1.5 <- dnearneigh(coords, d1 = 0, d2 = 1.5 * max_1nn, row.names = IDs)
knn.10 <- knearneigh(coords, k = 10)
knn.10 <- knn2nb(knn.10)


# to a weights matrix
dist.1.5 <- nbdists(nb.1.5,spdf_street) # or knn.10
#dist.1.5 <- lapply(dist.25,function(x) exp(-0.5 * (x / 2500)^2))
mat.1.5 <- nb2mat(nb.1.5,glist=dist.1.5,style="W")
W <- as(mat.1.5,"dgCMatrix")

## run the sar() function
res.formula <- price ~. 

model <- lm(formula=res.formula,data=df_street_noNA)
betas= coef(lm(formula=res.formula, data=df_street_noNA))

# minus NA coefficients
betas= coef(lm(formula=res.formula,
               data=df_street_noNA[, -c(1:5,81, 92,118:121,128,130,134,137:140,143,146,149,152,155:158,
                                       126, 162,165,168,171,174,177:180,186,189,192:199)]))

pars=list(rho = 0.5, sigma2e = 2.0, betas = betas)

res <- sar(res.formula,data=df_street_noNA[, -c(1:5,81,92,118:121,128,130,134,137:140,143,146,149,152,155:158,
                                                126, 162,165,168,171,174,177:180,186,189,192:199)],
           W=W, burnin=5000, Nsim=10000, thinning=0, parameters.start=pars)#changed thinning to zero
summary(res)
