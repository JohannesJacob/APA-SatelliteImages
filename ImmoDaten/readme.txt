Änderungen:

1. Alle anderen Städte außer Berlin sowie die zugehörigen Dummy-Variablen entfernt
2. "Street" in zwei verschiedene Features aufgeteilt: Straße und Hausnummer
3. Straßennamen wurden vereinheitlicht (Straße, Straße, ... wurde alle zur Str. bzw str.)
4. Rudimentäre Spalten entfernt, die nur einen Wert enthalten
5. Für alle fehlenden Straßennamen und Hausnummern den wert "(missing)" eingefügt. Dummy-Variable "AdressIncomplete" eingeführt, wobei eine 1 angibt, dass die Adresse fehlt