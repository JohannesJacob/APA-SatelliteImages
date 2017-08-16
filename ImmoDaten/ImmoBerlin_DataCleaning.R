### TODO ###-----------------------------------------------------------------------------------------------
# [X] NAs entfernen/imputen
# [X]  Straßen vereinheitlichen: 
#       - GUNTERSTRAßE / GUNTERSTRASSE vereinheitlichen
#       - Königsalle (1e zu wenig) + Koenigsallee --> Königsallee
#       - "Otto Suhr Allee " --> "Otto-Suhr-Allee "
#       - "Rigaerstr. " --> "Rigaer Str. "
#       - "Tile Brügge Weg " --> "Tile-Brügge-Weg "
#       - "Weißenburger STraße ", "Weißenburgerstr. " --> "Weißenburger Str. "
#       - "Wendenschloßstr. " --> "Wendenschlossstr. "
#       - "Wichmannstr " --> "Wichmannstr. "
#       - "Wilhelmine Gemberg Weg " --> "Wilhelmine Gemberg Weg "
# [X]  Straßen als eigenes Feature
#       - Sonderfall: Platz des 4. Juni, "Str. " --> "Str. 113"
# [X]   Checken, welche Spalten alle den selben Wert enthalten --> Rausschmeißen. ggf apply-Funktion
#----------------------------------------------------------------------------------------------------------
##### Readme #####
# Hinweis: Um den Code zu replizieren muss die ursprüngliche Datei final_final_final.csv im wd sein

# 1. Andere Städte Rausgeschmissen
# 2. "Street" in zwei verschiedene Features aufgesplitted (Straße und Nr.)
# 3. Straßennamen vereinheitlichen
# 4. Überprüfen, welche Spalten nur einen Wert enthalten
# 5. MV imputieren

# End Readme -------------------------------------------------------------------------------------------

ImmoDaten <- read.csv("final_final_final.csv", encoding = "UTF-8")


# 1. Andere Städte droppen ---------------------------------------------------------------------------
# select all observations with "Berlin" as City, drop dummy variables for cities
ImmoBerlin <- ImmoDaten[which(ImmoDaten$berlin==1),-(7:26)]


# 2. Aufteilen von Straße und Nr. ------------------------------------------------------------------------

# neue spalten einfügen
ImmoBerlinSep <- cbind(Str = "", StrNo = 0, ImmoBerlin)

# leere Vektoren initalisieren (für for-schleife)
Streets <- as.matrix(ImmoBerlinSep$Street) # ziehe Straßen als Char-Vector raus
Strassen <- vector(mode="character", length=length(Streets)) # init Strassenvektor
StrNummern <- vector(mode="character", length=length(Streets)) # init StrNummernvektor

for (i in 1:length(Streets)){
  if(Streets[i]==""){next} # ueberspringe Eintrag, falls leerer String
  else # falls nicht leer, tue:
    len <- nchar(Streets[i]) # Speichere laenge des Strings
    stringvector <- unlist(strsplit(Streets[i], split = "")) 
    numbers <- suppressWarnings(as.integer(stringvector))
  
  for(j in 1:len){ # gehe durch string durch
    if(!is.na(numbers[j])){ # bei der ersten Zahl die du findest mache:
      Strassen[i]   <- paste(stringvector[1:(j - 1)], collapse = "") # alles vor der ersten Zahl als Strasse
      StrNummern[i] <- paste(stringvector[j:length(stringvector)], collapse = "") # alles danach als StrNr
      break # breche innere schleife ab
    }
  }
}

ImmoBerlinSep$Str     <- as.factor(Strassen)
ImmoBerlinSep$StrNo   <- as.factor(StrNummern)
ImmoBerlinSep$Street  <- NULL


# 3. Straßennamen vereinheitlichen----------------------------------------------------------------------

# klein geschrieben
ImmoBerlinSep$Str <- as.factor(gsub("strasse", "str.", ImmoBerlinSep$Str))
ImmoBerlinSep$Str <- as.factor(gsub("straße", "str.", ImmoBerlinSep$Str))
# groß geschrieben
ImmoBerlinSep$Str <- as.factor(gsub("Strasse", "Str.", ImmoBerlinSep$Str))
ImmoBerlinSep$Str <- as.factor(gsub("Straße", "Str.", ImmoBerlinSep$Str))

### Anomalien Behandeln: (Achtung! idx Laufvariable)

# GUNTHERSTRAßE / GUNTHERSTRASSE
levels(ImmoBerlinSep$Str) <- c(levels(ImmoBerlinSep$Str), "Guntherstr. ")
ImmoBerlinSep$Str <- as.factor(ImmoBerlinSep$Str)
idx <- which(ImmoBerlinSep$Str == "GUNTHERSTRAßE "|ImmoBerlinSep$Str == "GUNTHERSTRASSE ")
ImmoBerlinSep[idx,]$Str <- "Guntherstr. "

# Königsalle / Koenigsallee
idx <- which(ImmoBerlinSep$Str == "Königsalle "|ImmoBerlinSep$Str == "Koenigsallee ")
ImmoBerlinSep[idx,]$Str <- "Königsallee "

# "Otto Suhr Allee " --> "Otto-Suhr-Allee "
idx <- which(ImmoBerlinSep$Str == "Otto Suhr Allee ")
ImmoBerlinSep[idx,]$Str <- "Otto-Suhr-Allee "

# "Rigaerstr. " --> "Rigaer Str. "
idx <- which(ImmoBerlinSep$Str == "Rigaerstr. ")
ImmoBerlinSep[idx,]$Str <- "Rigaer Str. "

# "Tile Brügge Weg " --> "Tile-Brügge-Weg "
idx <- which(ImmoBerlinSep$Str == "Tile Brügge Weg ")
ImmoBerlinSep[idx,]$Str <- "Tile-Brügge-Weg "

# "Weißenburger STraße ", "Weißenburgerstr. " --> "Weißenburger Str. "
idx <- which(ImmoBerlinSep$Str == "Weißenburger STraße "|ImmoBerlinSep$Str == "Weißenburgerstr. ")
ImmoBerlinSep[idx,]$Str <- "Weißenburger Str. "

# "Wendenschloßstr. " --> "Wendenschlossstr. "
idx <- which(ImmoBerlinSep$Str == "Wendenschloßstr. ")
ImmoBerlinSep[idx,]$Str <- "Wendenschlossstr. "

# "Wichmannstr " --> "Wichmannstr. "
idx <- which(ImmoBerlinSep$Str == "Wichmannstr ")
ImmoBerlinSep[idx,]$Str <- "Wichmannstr. "

# "Wilhelmine Gemberg Weg " --> "Wilhelmine Gemberg Weg "
idx <- which(ImmoBerlinSep$Str == "Wilhelmine Gemberg Weg ")
ImmoBerlinSep[idx,]$Str <- "Wilhelmine-Gemberg-Weg "

# "Str. 113", Platz des 4. Juli
levels(ImmoBerlinSep$Str) <- c(levels(ImmoBerlinSep$Str), "Str. 113", "Platz des 4. Juli ")
ImmoBerlinSep$Str <- as.factor(ImmoBerlinSep$Str)

ImmoBerlinSep[which(ImmoBerlinSep$Str == "Str. "),]$Str <- "Str. 113"
ImmoBerlinSep[which(ImmoBerlinSep$Str == "Platz des "),]$Str <- "Platz des 4. Juli "

# "0"
ImmoBerlinSep[which(ImmoBerlinSep$Str == "0"),] <- ""

# drop unused factor levels
ImmoBerlinSep$Str <- factor(ImmoBerlinSep$Str)

# check
levels(ImmoBerlinSep$Str)
which(ImmoBerlinSep$Str == "0")


# 4. Überprüfen, welche Spalten nur selbe Werte enthalten -------------------------------------------------

Spalten <- vector(mode="integer", length=ncol(ImmoBerlinSep)) # init Ergebnisvektor: Enthält Anzahl Unique-Werte für jeder Spalte

for(i in 1:ncol(ImmoBerlinSep)){
  Spalten[i] <- length(unique(ImmoBerlinSep[,i]))
}

any(Spalten == 1) # False, daher enthält jede Spalte Information.
# Aber:
which(ImmoBerlinSep$Isfloor_0 == "")
which(ImmoBerlinSep$Isfloor_3 == "")
# Observatation 1937 enthält nur leere werte:
View(ImmoBerlinSep[1937,])
# --> Löschen
ImmoBerlinSep <- ImmoBerlinSep[-1937,]

# nochmal checken ob sich was ändert

Spalten <- vector(mode="integer", length=ncol(ImmoBerlinSep)) # init Ergebnisvektor: Enthält Anzahl Unique-Werte für jeder Spalte

for(i in 1:ncol(ImmoBerlinSep)){
  Spalten[i] <- length(unique(ImmoBerlinSep[,i]))
}

# --> 7 Spalten mit nur einem unique-Wert. Rausschmeißen
ImmoBerlinSep <- ImmoBerlinSep[,-(which(Spalten == 1))]


# 5. impute Missing Factor levels (optional) ----------------------------------------------------------------------

# Dummy - Variable für unvollständige Einträge einführen:
# "incomplete" 0: Alles da, 1: Adresse fehlt
ImmoBerlinSep <- cbind(ImmoBerlinSep, AddressIncomplete = -1)

# reset
#ImmoBerlinSep$AddressIncomplete <- -1 

# Beides da: 0
ImmoBerlinSep[which(ImmoBerlinSep$Str != "" & ImmoBerlinSep$StrNo != ""), "AddressIncomplete"] <- 0
# Adresse fehlt: 1
ImmoBerlinSep[which(ImmoBerlinSep$Str == "" & ImmoBerlinSep$StrNo == ""), "AddressIncomplete"] <- 1

View(ImmoBerlinSep[,c(1,2,195)])

# Str
levels(ImmoBerlinSep$Str) <- c(levels(ImmoBerlinSep$Str), "(missing)")
ImmoBerlinSep[ImmoBerlinSep$Str=="",]$Str <- "(missing)"

# StrNo
levels(ImmoBerlinSep$StrNo) <- c(levels(ImmoBerlinSep$StrNo), "(missing)")
ImmoBerlinSep[ImmoBerlinSep$StrNo=="",]$StrNo <- "(missing)"

### Theoretisch sollten jetzt alles fehlenden Werte draußen sein, sodass eine Regression gestartet werden kann
any(ImmoBerlinSep =="")
anyNA(ImmoBerlinSep)

# schreibe auf platte ------------------------------------------------------------------------------------
write.csv(ImmoBerlinSep, file = "ImmoBerlinCleaned.csv")
