# Spatial Auto-Regression on Immo-Data
library(HSAR)

df_street <- read.csv("Immo_streetCoordinates.csv")
df_street_noNA <- df_street[complete.cases(df_street),]

# Convert data frame to a spatial object
library(sp)
spdf_street <- SpatialPointsDataFrame(coords = df_street_noNA[, c("lng", "lat")],
                                      data = df_street_noNA)

# extract the land parcel level spatial weights matrix
library(spdep)
nb.25 <- dnearneigh(spdf_street,0,2500)

# to a weights matrix
dist.25 <- nbdists(nb.25,spdf_street)
dist.25 <- lapply(dist.25,function(x) exp(-0.5 * (x / 2500)^2))
mat.25 <- nb2mat(nb.25,glist=dist.25,style="W")
W <- as(mat.25,"dgCMatrix")

## run the sar() function
res.formula <- lnprice ~ lnarea + lndcbd + dsubway + dpark + dele + 
  popden + crimerate + as.factor(year)

betas= coef(lm(formula=res.formula,data=df_street_noNA))

pars=list( rho = 0.5, sigma2e = 2.0, betas = betas )
