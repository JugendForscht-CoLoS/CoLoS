//
//  Earth.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation

class Earth {
    // Radius der Pole und des Äquators
    private static let rPoles = 6357.0 //km
    private static let rÄquator = 6378.0 //km
    // bei übergebenem Breiten- und Längengrad wird Punkt in kartesische Koordinaten umgerechnet und zurückgegeben
    static func getCartesianCoordinates(latitude: Double, longitude: Double) -> Point {
        
        let phi = toRadians(latitude)
        let lambda = toRadians(longitude)
        
        let x2D = sqrt((rPoles * rPoles) / (tan(phi) * tan(phi) + (rPoles / rÄquator) *  (rPoles / rÄquator)))
        
        let y2D = tan(phi) * x2D
        
        let r = sqrt(x2D * x2D + y2D * y2D)
        
        return Point(phi: phi, lambda: lambda, r: r)
    }
    // @return der Normalvektor einer Ebene eines beliebigen Ortes (Breiten- / Längengrad) auf der Erde
    static func getNormalVectorOfTangentailPlane(latitude: Double, longitude: Double) -> Vector {
        
        let p = Earth.getCartesianCoordinates(latitude: latitude, longitude: longitude)
        
        let a = rÄquator * rÄquator
        let b = rPoles * rPoles
        
        return Vector(x: p.x, y: p.y, z: p.z * (a/b))
    }
}
