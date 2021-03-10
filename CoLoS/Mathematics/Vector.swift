//
//  Vector.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
// eine Klasse um mit Vektoren des R3 zu arbeiten
struct Vector: CustomStringConvertible {
    
    let x: Double
    let y: Double
    let z: Double
    // Betrag
    let abs: Double
    
    var description: String {
        
        return "(\(Float(x))) (\(Float(y))) (\(Float(z)))"
    }
    // Konstruktor für einen Ortsvektor
    init(x: Double, y: Double, z: Double) {
        
        self.x = x
        self.y = y
        self.z = z
        
        abs = sqrt(x * x + y * y + z * z)
    }
    // Konstruktor für einen Vektor von einem zu einem anderen Punkt im Raum R3
    init(from p: Point, to q: Point) {
        
        let x = q.x - p.x
        let y = q.y - p.y
        let z = q.z - p.z
        
        self.x = x
        self.y = y
        self.z = z
        
        abs = sqrt(x * x + y * y + z * z)
    }
    // Vektoroperatoren:

    // addiert zwei Vektoren
    static func + (vector1: Vector, vector2: Vector) -> Vector {
        
        return Vector(x: vector1.x + vector2.x, y: vector1.y + vector2.y, z: vector1.z + vector2.z)
    }
    // multipliziert einen Vektor mit einem Skalar
    static func * (s: Double, vector: Vector) -> Vector {
        
        return Vector(x: s * vector.x, y: s * vector.y, z: s * vector.z)
    }
    // Skalarprodukt zweier Vektoren
    static func * (vector1: Vector, vector2: Vector) -> Double {
        
        return vector1.x * vector2.x + vector1.y * vector2.y + vector1.z * vector2.z
    }
    // Kreuzprodukt
    static func * (a: Vector, b: Vector) -> Vector {
        
        return Vector(x: a.y * b.z - a.z * b.y, y: a.z * b.x - a.x * b.z, z: a.x * b.y - a.y * b.x)
    }
    // aufgespannter Winkel zweier Vektoren
    static func ^ (vector1: Vector, vector2: Vector) -> Double {
        
        let angle = acos((vector1 * vector2) / (vector1.abs * vector2.abs))
        
        return angle
    }
}
