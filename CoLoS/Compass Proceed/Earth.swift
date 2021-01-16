//
//  Earth.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation

class Earth {
    
    private static let rPoles = 6357.0 //km
    private static let rÄquator = 6378.0 //km
    
    static func getCartesianCoordinates(latitude: Double, longitude: Double) -> Point {
        
        let phi = toRadians(latitude)
        let lambda = toRadians(longitude)
        
        let x2D = sqrt((rPoles * rPoles) / (tan(phi) * tan(phi) + (rPoles / rÄquator) *  (rPoles / rÄquator)))
        
        let y2D = tan(phi) * x2D
        
        let r = sqrt(x2D * x2D + y2D * y2D)
        
        return Point(phi: phi, lambda: lambda, r: r)
    }
    
    static func getNormalVectorOfTangentailPlane(latitude: Double, longitude: Double) -> Vector {
        
        let p = Earth.getCartesianCoordinates(latitude: latitude, longitude: longitude)
        
        let variable = sqrt(p.x * p.x + p.y * p.y)
        let a = rÄquator * rÄquator
        let b = rPoles * rPoles
        let survaceGradient = -1 * (variable / (a * b) * sqrt((1 / b) - (variable * variable / a * b)))
        
        return Vector(x: p.x, y: p.y, z: variable * (-1 * (1 / survaceGradient)))
    }
}
