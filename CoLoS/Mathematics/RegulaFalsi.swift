//
//  RegulaFalsi.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
// Methode zum Lösen von Nullstellen mit Regula Falsi
func solve(xStart: Double, f: (Double) -> Double) throws -> Double {
    
    let e: Double = pow(10, -16) //accuracy of Double
    
    var a = xStart
    var b = xStart + pow(10, -15)
    
    var i = 0
    // um das bestmögliche Ergebnis für den Computer zu erhalten, wird die Schleife bei der höchsten Genauigkeit für ein Double gestoppt
    while abs(a - b) > e {
        // das Verfahren stoppt, wenn eine Sekante horizontal, also parallel zur x achse liegt
        if f(a) == f(b) {
            
            throw RegulaFalsiError.horizontalSecant
        }
        // der eigentliche Iterationsschritt
        let aAlt = a
        a = aAlt - f(aAlt) * ((b - aAlt) / (f(b) - f(aAlt)))
        b = aAlt
        
        i += 1
        // das Verfahren stoppt nach 100 Iterationen
        if i == 100 {
            
            throw RegulaFalsiError.notFoundSolution
        }
    }
    
    return a
}

enum RegulaFalsiError: Error {
    
    case horizontalSecant
    
    case notFoundSolution
}
