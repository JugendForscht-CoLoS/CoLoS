//
//  Point.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
// Ein Punkt in einem 3D Koordinatensystem wird in dieser Klasse durch seine 3 karteischen Koordianten x|y|z (>kartesisches Koordinatensystem<) 
// oder seine Polarkoordinaten (lambda)|(phi)|r angegeben. Lambda und Phi lassen sich dabei als Längen- und Breitengrad verstehen, r ist der Abstand zum Ursprung
struct Point: CustomStringConvertible {
    // kartesische Koordinaten
    let x: Double
    let y: Double
    let z: Double
    // Polarkoordinaten
    let phi: Double
    let lambda: Double
    let r: Double
    // gibt kartesische sowie Polarkoordinaten zurück
    var description: String {
        
        return "<cartesian> (\(Float(x)) | \(Float(y)) | \(Float(z))); <polar> (\(Float(toDegrees(lambda)))° | \(Float(toDegrees(phi)))° | \(Float(r)))"
    }
    // Konstruktor, bei dem Polarkoordinaten übergeben werden und in karteisische Koordinaten umgewandelt werden
    init(phi: Double, lambda: Double, r: Double) {
        
        self.lambda = lambda
        self.phi = phi
        self.r = r
        
        x = r * cos(phi) * cos(lambda)
        y = r * sin(lambda) * cos(phi)
        z = r * sin(phi)
    }
    // Konstruktor, bei dem karteisische Koordinaten übergeben werden und in Polarkoordinaten umgewandelt werden
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
