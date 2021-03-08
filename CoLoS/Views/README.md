#  UI der App

## Folgende Views gibt es:

* __ContentView__
* __MeasurementProcedureView__
* __MeasurementView__
* __CameraView__
* __TimerView__
* __LocationView__
* __MapView__

## ContentView

`ContentView` ist die View, die nach dem Starten der App angezeigt wird. Sie verweist über einen `NavigationLink` auf die `MeasurementProcedureView`.

## MeasurementProcedureView

Diese View bildet eine Controller-Funktion. Sie wechselt zwischen `MeasurementView`, `TimerView` und `LocationView`.  Zudem wird hier der komplette Vorgang von der Messung bis zur Ausgabe gesteuert.

## MeasurementView

Diese View steuert das Messen. Es wird die `CameraView` angezeigt und mittels des `AlignmentManagers` Elevation und Azimut der Sonne gemessen.

## CameraView

Diese View greift über eine `AVCaptureSession` auf die Kamera zu. Das Bild wird angezeigt und an den `MLManager` übermittelt.

## TimerView

Diese View visualisiert die Wartezeit.

## LocationView

Diese View prüft den berechneten Standort und zeigt ihn über die `MapView` an.

## MapView

Diese View zeichnet einen gegebenen Standort auf einer geladenen Offline-Karte ein.
