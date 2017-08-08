#Change folder structure
library(caret)

#split into training and testing
idx <- createDataPartition(streetOnly$WOL, p = 0.8)
streetOnly$dataPartition <- NULL
streetOnly$dataPartition[idx]  <- "train"
streetOnly$dataPartition[-idx]  <- "testing"


sourcepath <- "C:/Users/Johannes/Documents/SatelliteImages/"  

for (i in 1:nrow(streetOnly)) {
  object <- paste0("Bild_", i, ".png")
  from   <- paste0(sourcepath, object)
  
  if (streetOnly$dataPartition[i] == "train"){
    targetpath <- "C:/Users/Johannes/Documents/SatelliteImages/train/"
    if (streetOnly$WOL[i]=="gut"){
      to     <- paste0(targetpath, "gut/","gut", i, ".png")
    } else {
      if (streetOnly$WOL[i]=="mittel"){
        to     <- paste0(targetpath, "mittel/","mittel", i, ".png")
      } else {
        to     <- paste0(targetpath, "einfach/","einfach", i, ".png") 
      }
    }  
  } else {
  
    if (streetOnly$dataPartition[i] == "testing"){
      targetpath <- "C:/Users/Johannes/Documents/SatelliteImages/validation/"
      if (streetOnly$WOL[i]=="gut"){
        to     <- paste0(targetpath, "gut/","gut", i, ".png")
      } else {
        if (streetOnly$WOL[i]=="mittel"){
          to     <- paste0(targetpath, "mittel/","mittel", i, ".png")
        } else {
          to     <- paste0(targetpath, "einfach/","einfach", i, ".png") 
        }
      }  
    }
  }  
  
  file.rename(from = from,  to = to)
}