//
//  CoLoSManager.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreLocation

class CoLoSManager {
    
    private let magneticSouthPole = Earth.getCoordinate(latitude: 86.502, longitude: 164.036) //https://www.ngdc.noaa.gov/geomag/GeomagneticPoles.shtml (2020)
    private let geographicNorthPole = Earth.getCoordinate(latitude: 0, longitude: 0)
    
    var azimuts: (Double?, Double?)
    var elevations: (Double?, Double?)
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
    
    func computeUsersLocation() -> ComputedLocation {
        
        guard let azimut0 = azimuts.0, let azimut1 = azimuts.1, let elevation0 = elevations.0, let elevation1 = elevations.1, let time = time, let date = date else { return ComputedLocation(CLLocationCoordinate2D(latitude: 0, longitude: 0))} //Hier muss sich was ändern!!!
        
        do {
            
            let beta = try solve(xStart: 0) { alpha in
                
                let coordinates = getCoordinate(azimut: (azimut0, azimut1), beta: alpha, elevation: (elevation0, elevation1), time: time, date: date)
                
                let p = Earth.getCoordinate(latitude: toDegrees(coordinates.latitude), longitude: toDegrees(coordinates.longitude))
                
                return getAngleBeetween(g: geographicNorthPole, p: p, m: magneticSouthPole) - alpha
            }
            
            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: beta, elevation: (elevation0, elevation1), time: time, date: date))
        }
        catch RegulaFalsiError.notFoundSolution {
            
            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date))
        }
        catch RegulaFalsiError.horizontalSecant {
            
            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date))
        }
        catch {
            
            return ComputedLocation(getCoordinate(azimut: (azimut0, azimut1), beta: 0, elevation: (elevation0, elevation1), time: time, date: date))
        }
    }
    
//    private func getGeographicNorth(with beta: Double) -> Double {
//
//        guard let azimut0 = azimuts.0, let azimut1 = azimuts.1, let elevation0 = elevations.0, let elevation1 = elevations.1, let time = time, let date = date else { return Double.nan} //Hier muss sich was ändern!!!
//
//        let coordinate = getCoordinates(azimut: (azimut0, azimut1), beta: beta, elevation: (elevation0, elevation1), time: time, date: date)
//        let p = Earth.getCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
//
//        let pMS = Vector(from: p, to: magneticSouthPole)
//        let pGN = Vector(from: p, to: geographicNorthPole)
//
//        return pMS ^ pGN
//    }
    
    private func getAngleBeetween(g: Point, p: Point, m: Point) -> Double {
        
        let origin = Point(x: 0, y: 0, z: 0)
        let og = Vector(from: origin, to: g)
        let op = Vector(from: origin, to: p)
        let om = Vector(from: origin, to: m)
        
        let n = Earth.getNormalVectorOfTangentailPlane(latitude: p.phi, longitude: p.lambda)
        
        let sG = ((n * op) - (n * og)) / (n * n)
        let sM = ((n * op) - (n * om)) / (n * n)
        
        let prG = og + sG * n
        let prM = om + sM * n
        
        let pPrM = Vector(from: p, to: Point(x: prM.x, y: prM.y, z: prM.z))
        let pPrG = Vector(from: p, to: Point(x: prG.x, y: prG.y, z: prG.z))
        
        let beta = pPrM ^ pPrG
        
        if smallAngle(smallAngle(m.lambda) - smallAngle(p.lambda)) < Double.pi {
            
            return beta
        }
        else {
            
            return -1 * beta
        }
    }
    
    private func getCoordinate(azimut: (Double, Double), beta: Double, elevation: (Double, Double), time: Double, date: Double) -> RadiansCoordinate {
        
        let azimut0 = azimut.0 + beta
        let azimut1 = azimut.1 + beta
        
        let phi = atan( -1 * tan(elevation.1) * cos(azimut1 - Double.pi) - sin(azimut1 - Double.pi) * (azimut1 - azimut0) / (elevation.1 - elevation.0))
        
        let woz = (648000 / (15 * Double.pi)) * (atan( sin(azimut1 - Double.pi) / (cos(azimut1 - Double.pi) * sin(phi) + tan(elevation.1) *  cos(phi))) + Double.pi)
        let lambda = (15 * Double.pi / 648000) * (woz - ZG(date) - time)

        return RadiansCoordinate(latitude: phi, longitude: lambda)
    }
}
