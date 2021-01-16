#  Messung der Ausrichtung des Smartphones

Der AlignmentManager ist die Klasse, die Azimut und Elevation der Sonne misst. Ein Objekt dieser Klasse stellt in seinen Instanzvariablen elevation und azimut die aktuelle Ausrichtung des Smartphones zu Verfügung.
Die Klasse arbeitet im Allgemeinen über das Framework CoreMotion. Der CMMotionManager erlaubt den Zugriff auf alle Sensoren des Smartphones.
Im Konstruktor wird dieser initialisiert und vorbereitet. Die Methode deviceMotionHasUpdated wird als ComletionHandler-Methode an den CMMotionManager übergeben. Sie wird immer dann aufgerufen, wenn die Sensoren neue Werte gemessen haben. In dieser Methode werden dann Azimut und Elevation berechnet.
