#  Kompass Verfahren (Compass Procedure)

Folgende Klassen / Strukturen / Enumerationen sind enthalten:
-

- `Earth`
- `Date`
- `ComputedLocation`
- `CoLoSManager`

Folgende globalen Variablen / Methoden sind enthalten:
-

- `ZG`
- `smallAngle`
- `toRadians`
- `toDegrees`


Earth
-

Die Klasse `Earth` modelliert die Erde mit Koordinaten von magnetischem Nordpol und magnetischen Südpol, bei gegebenem Breiten- und Längengrad können die kartesischen Koordinaten und der Normalvektor (der tangentialen Ebene des Standpunkts) berechnet werden.

Date
-

Die Erweiterung `Date` berechnet die für die Zeitgleichung notwendige Eingabe, die Zeit nach Jahresbeginn in Sekunden, und die Zeit nach Tagesbeginn 00:00 Uhr (wahre Ortszeit).

ComputedLocation
-

Die Struktur `ComputedLocation` soll neben den genauen Koordianten eine Fehlerberechnung enthalten.

CoLoSManager
-

Die Klasse `CoLoSManager` enthält alle Attribute und Funktionen zur Berechnung des Standorts, mit und ohne Kompassverfahren (Ausgleichswinkel beta)

ZG()
-

Die globale Methode `ZG()` gibt an einem Datum (übergeben wird die Zeit nach Jahresbeginn) die Differenz von wahrer und mittlere Ortszeit an.

smallAngle()
-

Die globale Methode `smallAngle()` gibt an einem Datum die Differenz von wahrer und mittlere Ortszeit an.

RegulaFalsiError
-
 Die Enumeration `RegulaFalsiError` definiert Fehler, die bei `solve()` auftreten können.
