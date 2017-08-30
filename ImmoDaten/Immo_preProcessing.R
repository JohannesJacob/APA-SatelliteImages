# Immo preprocessing

df_street <- read.csv("Immo_streetCoordinates.csv")
df_street_noNA <- df_street[complete.cases(df_street),]

# remove outlier
df_street_noNA <- df_street_noNA[-which(df_street_noNA$price==max(df_street_noNA$price)),]

# log price and size
df_street_noNA$price <- log(df_street_noNA$price)
df_street_noNA$size  <- log(df_street_noNA$size)

df_street_noNA$busMin  <- log(df_street_noNA$busMin+1)
df_street_noNA$docMin   <- log(df_street_noNA$docMin+1)
df_street_noNA$smMin  <- log(df_street_noNA$smMin+1)
df_street_noNA$foodMin  <- log(df_street_noNA$foodMin+1)
df_street_noNA$parkMin  <- log(df_street_noNA$parkMin+1)
df_street_noNA$schoolMin  <- log(df_street_noNA$schoolMin+1)
df_street_noNA$trainMin  <- log(df_street_noNA$trainMin+1)
df_street_noNA$airMin  <- log(df_street_noNA$airMin+1)
df_street_noNA$uniMin  <- log(df_street_noNA$uniMin+1)
df_street_noNA$collegeMin  <- log(df_street_noNA$collegeMin+1)
df_street_noNA$artSchoolMin  <- log(df_street_noNA$artSchoolMin+1)
df_street_noNA$musicSchoolMin  <- log(df_street_noNA$musicSchoolMin+1)

df_street_noNA[,c(127:181,183:191)] <- sapply(df_street_noNA[,c(127:181,183:191)], log)

# writing output
write.csv(df_street_noNA, "Immo_preProcessed.csv")


