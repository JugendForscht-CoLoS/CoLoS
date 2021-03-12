//
//  CoLoSManager.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreLocation
// Hinweis: der logger speichert Einträge, sodass diese im Nachhinein abgerufen werden können
class CoLoSManager {
    // die Attribute der bekannten Koordinaten von magnetischem Südpol und geographischen Nordpol
    private let magneticSouthPole = Earth.getCartesianCoordinates(latitude: 86.415, longitude: 157.690) //https://www.ngdc.noaa.gov/geomag/GeomagneticPoles.shtml (2021)
    private let geographicNorthPole = Earth.getCartesianCoordinates(latitude: 0, longitude: 0)
    
    var azimuts: (Double?, Double?) //Bogenmaß
    var elevations: (Double?, Double?) //Bogenmaß
    var time: Double?
    var date: Double?
    // bei der erstem Messung werden Azimuzt, Elevation, Zeit (Sekunden nach 00:00Uhr) und Datum (Zeit nach Jahresbeginn in Sekunden) übergeben/gespeichert
    func addFirstMeasurement(_ measurement: Measurement) {
        
        azimuts.0 = measurement.azimut
        elevations.0 = measurement.elevation
        self.time = Double(measurement.time)
        self.date = Double(measurement.date)
    }
    // bei der zweiten Messung werden nur Azimut und Elevation gespeichert, um die Sonnenbewegung festzustellen
    func addSecondMeasurement(_ measurement: Measurement) {
        
        azimuts.1 = measurement.azimut
        elevations.1 = measurement.elevation
    }
    // Methode, die getCoordinate aufruft und ohne dem Kompassverfahren arbeitet (ohne Kompassverfahren, d. h. ohne beta)
    //@return die berechnete Position, angegeben in (°) 
    func computeUsersLocation() -> ComputedLocation { //Ohne Kompassverfahren (funktioniert)
        
        guard let azimut0 = azimuts.0, let azimut1 = azimuts.1, let elevation0 = elevations.0, let elevation1 = elevations.1, let time = time, let date = date else { return ComputedLocation(CLLocationCoordinate2D(latitude: 0, longitude: 0))}
        
        let coordinate = getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date)
        
        return ComputedLocation(coordinate)
    }
    // Methode, die mit Azimut, Elevation, dem Asgleichswinkel beta (Azimut) dem Zeit und dem Datum den Standort des Benutzers berechnet
    private func getCoordinate(azimut: (Double, Double), beta: Double, elevation: (Double, Double), time: Double, date: Double) -> RadiansCoordinate {
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID)): beta = \(toDegrees(beta))°")
        // der neue Azimut ist der alte Azimut plus dem Ausgleichswinkel
        let azimut0 = azimut.0 + beta
        let azimut1 = azimut.1 + beta
        // Berechnung des Breitengrads
        let phi = atan( -1 * tan(elevation.0) * cos(azimut0 - Double.pi) - sin(azimut0 - Double.pi) * (azimut1 - azimut0) / (elevation.1 - elevation.0))
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID)): dA/dh = \((azimut1 - azimut0) / (elevation.1 - elevation.0))")
        // Berechnung der wahren Ortszeit ...
        let woz = (648000 / (15 * Double.pi)) * (atan(sin(azimut0 - Double.pi) / (cos(azimut0 - Double.pi) * sin(phi) + tan(elevation.0) *  cos(phi))) + Double.pi)
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID)): woz = \(woz)s")
        // ... für den Längengrad
        let lambda = (15 * Double.pi / 648000) * (woz - ZG(date) - time)
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID, privacy: .public)): latitude = \(toDegrees(phi))°; longitude = \(toDegrees(lambda))°")

        return RadiansCoordinate(latitude: phi, longitude: lambda)
    }
    // Methode, die den Standort des Benutzers berechnet (mit Kompassverfahren)
    func computeUsersLocationWithCompassProcedure() -> ComputedLocation { //Mit Kompassverfahren (noch nicht getestet)

        guard let azimut0 = azimuts.0, let azimut1 = azimuts.1, let elevation0 = elevations.0, let elevation1 = elevations.1, let time = time, let date = date else { return ComputedLocation(CLLocationCoordinate2D(latitude: 0, longitude: 0))}

        do {
            // "solve" wird der Startwert für x übergeben und die hier implementierte Funktion, dessen Nullpunkt durch Regula Falsi ermittelt wird
            let beta = try solve(xStart: 0) { alpha in
                // zunächst wird der Standort ohne Ausgleichswinkel berechnet, dieser wird über den Verlauf angepasst
                let coordinates = getCoordinate(azimut: (azimut0, azimut1), beta: alpha, elevation: (elevation0, elevation1), time: time, date: date)
                // Umwandlung der Koordinaten (Breiten- und Längengrad) in kartesische Koordianten
                let p = Earth.getCartesianCoordinates(latitude: toDegrees(coordinates.latitude), longitude: toDegrees(coordinates.longitude))
                logger.debug("Earth(\(MeasurementProcedureView.taskID)): p = \(p)")
                // der Winkel von dem berechneten Standort zu dem magnetischen Südpol und dem geographischen Nordpol wird berechnet und neu in die Funktion eingesetzt
                return getAngleBeetween(g: geographicNorthPole, p: p, m: magneticSouthPole) - alpha
            }

            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: beta, elevation: (elevation0, elevation1), time: time, date: date))
        }
        // Regula Falsi Errors
        catch RegulaFalsiError.notFoundSolution {
            
            logger.error("CoLoSManager(\(MeasurementProcedureView.taskID)): RegulaFalsiError: not found a solution")

            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date))
        }
        catch RegulaFalsiError.horizontalSecant {
            
            logger.error("CoLoSManager(\(MeasurementProcedureView.taskID)): RegulaFalsiError: horizontal secant")

            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date))
        }
        catch {
            
            logger.error("CoLoSManager(\(MeasurementProcedureView.taskID)): Error occured: \(error.localizedDescription)")

            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date))
        }
    }
    // berechnet den Winkel zwischen 3 Punkten in R3, für das Kompassverfahren
    //@param g: Geographischer Nordpol, p: Standort, m: magneitscher Südpol
    //@return Ausgleichswinkel beta für den Azimut 
    private func getAngleBeetween(g: Point, p: Point, m: Point) -> Double { //Winkelfunktion W
        // Initialisierung der Ortsvektoren
        let origin = Point(x: 0, y: 0, z: 0)
        let og = Vector(from: origin, to: g)
        let op = Vector(from: origin, to: p)
        let om = Vector(from: origin, to: m)
        // Normalvektor des berechneten Standorts bzw des  Punktes, der Ursprung der beiden Vektoren ist, zwischen denen der Winkel berechnet wird
        let n = Earth.getNormalVectorOfTangentailPlane(latitude: p.phi, longitude: p.lambda)
        logger.debug("Earth(\(MeasurementProcedureView.taskID)): n = \(n)")
        // Berechnung der 
        let sG = ((n * op) - (n * og)) / (n * n)
        let sM = ((n * op) - (n * om)) / (n * n)
        // Berechnung der Vektoren
        let prG = og + sG * n
        let prM = om + sM * n
        // auf der Ebene projizierter Punkt des geographischen Nordpols (prG) und des magnetischen Südpols (sM)
        let pPrM = Vector(from: p, to: Point(x: prM.x, y: prM.y, z: prM.z))
        let pPrG = Vector(from: p, to: Point(x: prG.x, y: prG.y, z: prG.z))
        // Ausgleichswinkel beta
        let beta = pPrM ^ pPrG
        logger.debug("CoLoSManager(\(MeasurementProcedureView.taskID)): abs(beta) = \(toDegrees(beta)); longitudeMS = \(toDegrees(m.lambda)); longitudeP = \(toDegrees(p.lambda))")
        // noch nicht getestet, soll negativen Wert von beta "verhindern" sprich einen Wert zwischen 0° und 360° zurückgeben
        if smallAngle(smallAngle(m.lambda) - smallAngle(p.lambda)) < Double.pi {
            
            return beta
        }
        else {
            
            return -1 * beta
        }
    }
}
