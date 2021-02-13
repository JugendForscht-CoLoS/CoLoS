#  Mathematische Klassen

Folgende Klassen / Strukturen / Enumerationen sind enthalten:
-

- `Vector`
- `Point`
- `RegulaFalsiError`

Folgende globalen Variablen / Methoden sind enthalten:
-

- `solve`

Vector
-

Die Struktur `Vector` repräsentiert R3-Vektoren. Es sind alle benötigten inneren und äußeren Verknupfungen implementiert.

Point
-

Die Struktur `Point` repräsentiert Punkte im Raum. Zudem können kartesische Koordinaten in Polar-Koordinaten (und umgekehrt) umgewandelt werden.

solve()
-

Die globale Methode `solve()` löst eine übergebene Gleichung durch das numerische Lösungsverfahren Regula Falsi.

RegulaFalsiError
-
 Die Enumeration `RegulaFalsiError` definiert Fehler, die bei `solve()` auftreten können.

