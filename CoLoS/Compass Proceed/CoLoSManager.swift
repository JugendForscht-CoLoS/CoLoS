//
//  CoLoSManager.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreLocation

class CoLoSManager {
    
    private let magneticSouthPole = Earth.getCartesianCoordinates(latitude: 86.415, longitude: 157.690) //https://www.ngdc.noaa.gov/geomag/GeomagneticPoles.shtml (2021)
    private let geographicNorthPole = Earth.getCartesianCoordinates(latitude: 0, longitude: 0)
    
    var azimuts: (Double?, Double?) //Bogenmaß
    var elevations: (Double?, Double?) //Bogenmaß
    var time: Double?
    var date: Double?
    
    func addFirstMeasurement(azimut: Double, elevation: Double, time: Double, date: Double) {
        
        azimuts.0 = azimut
        elevations.0 = elevation
        self.time = time
        self.date = date
    }
    
    func addSecondMeasurement(azimut: Double, elevation: Double) {
        
        azimuts.1 = azimut
        elevations.1 = elevation
    }
    
    func computeUsersLocation() -> ComputedLocation { //Ohne Kompassverfahren (funktioniert)
        
        guard let azimut0 = azimuts.0, let azimut1 = azimuts.1, let elevation0 = elevations.0, let elevation1 = elevations.1, let time = time, let date = date else { return ComputedLocation(CLLocationCoordinate2D(latitude: 0, longitude: 0))}
        
        let coordinate = getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date)
        
        return ComputedLocation(coordinate)
    }
    
    private func getCoordinate(azimut: (Double, Double), beta: Double, elevation: (Double, Double), time: Double, date: Double) -> RadiansCoordinate {
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID)): beta = \(toDegrees(beta))°")
        
        let azimut0 = azimut.0 + beta
        let azimut1 = azimut.1 + beta
        
        let phi = atan( -1 * tan(elevation.1) * cos(azimut1 - Double.pi) - sin(azimut1 - Double.pi) * (azimut1 - azimut0) / (elevation.1 - elevation.0))
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID)): dA/dh = \((azimut1 - azimut0) / (elevation.1 - elevation.0))")
        
        let woz = (648000 / (15 * Double.pi)) * (atan(sin(azimut1 - Double.pi) / (cos(azimut1 - Double.pi) * sin(phi) + tan(elevation.1) *  cos(phi))) + Double.pi)
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID)): woz = \(woz)s")
        
        let lambda = (15 * Double.pi / 648000) * (woz - ZG(date) - time)
        
        logger.notice("CoLoSManager(\(MeasurementProcedureView.taskID, privacy: .public)): latitude = \(toDegrees(phi))°; longitude = \(toDegrees(lambda))°")

        return RadiansCoordinate(latitude: phi, longitude: lambda)
    }
    
    func computeUsersLocationWithCompassProcedure() -> ComputedLocation { //Mit Kompassverfahren (noch nicht getestet)

        guard let azimut0 = azimuts.0, let azimut1 = azimuts.1, let elevation0 = elevations.0, let elevation1 = elevations.1, let time = time, let date = date else { return ComputedLocation(CLLocationCoordinate2D(latitude: 0, longitude: 0))}

        do {

            let beta = try solve(xStart: 0) { alpha in

                let coordinates = getCoordinate(azimut: (azimut0, azimut1), beta: alpha, elevation: (elevation0, elevation1), time: time, date: date)

                let p = Earth.getCartesianCoordinates(latitude: toDegrees(coordinates.latitude), longitude: toDegrees(coordinates.longitude))
                logger.debug("Earth(\(MeasurementProcedureView.taskID)): p = \(p)")

                return getAngleBeetween(g: geographicNorthPole, p: p, m: magneticSouthPole) - alpha
            }

            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: beta, elevation: (elevation0, elevation1), time: time, date: date))
        }
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
    
    private func getAngleBeetween(g: Point, p: Point, m: Point) -> Double { //Winkelfunktion W
        
        let origin = Point(x: 0, y: 0, z: 0)
        let og = Vector(from: origin, to: g)
        let op = Vector(from: origin, to: p)
        let om = Vector(from: origin, to: m)
        
        let n = Earth.getNormalVectorOfTangentailPlane(latitude: p.phi, longitude: p.lambda)
        logger.debug("Earth(\(MeasurementProcedureView.taskID)): n = \(n)")
        
        let sG = ((n * op) - (n * og)) / (n * n)
        let sM = ((n * op) - (n * om)) / (n * n)
        
        let prG = og + sG * n
        let prM = om + sM * n
        
        let pPrM = Vector(from: p, to: Point(x: prM.x, y: prM.y, z: prM.z))
        let pPrG = Vector(from: p, to: Point(x: prG.x, y: prG.y, z: prG.z))
        
        let beta = pPrM ^ pPrG
        logger.debug("CoLoSManager(\(MeasurementProcedureView.taskID)): abs(beta) = \(toDegrees(beta)); longitudeMS = \(toDegrees(m.lambda)); longitudeP = \(toDegrees(p.lambda))")
        
        if smallAngle(smallAngle(m.lambda) - smallAngle(p.lambda)) < Double.pi {
            
            return beta
        }
        else {
            
            return -1 * beta
        }
    }
}
