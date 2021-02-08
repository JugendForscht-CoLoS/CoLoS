//
//  Point.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation

struct Point: CustomStringConvertible {
    
    let x: Double
    let y: Double
    let z: Double
    
    let phi: Double
    let lambda: Double
    let r: Double
    
    var description: String {
        
        return "<cartesian> (\(Float(x)) | \(Float(y)) | \(Float(z))); <polar> (\(Float(toDegrees(lambda)))° | \(Float(toDegrees(phi)))° | \(Float(r)))"
    }
    
    init(phi: Double, lambda: Double, r: Double) {
        
        self.lambda = lambda
        self.phi = phi
        self.r = r
        
        x = r * cos(phi) * cos(lambda)
        y = r * sin(lambda) * cos(phi)
        z = r * sin(phi)
    }
    
    init(x: Double, y: Double, z: Double) {
        
        self.x = x
        self.y = y
        self.z = z
        
        let r = sqrt(x*x + y*y + z*z)
        self.r = r
        
        let phi = asin(z / r)
        self.phi = phi
        
        lambda = asin(y / (r * cos(phi)))
    }
}
