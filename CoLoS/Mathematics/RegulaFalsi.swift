//
//  RegulaFalsi.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation

func solve(xStart: Double, f: (Double) -> Double) throws -> Double {
    
    let e: Double = pow(10, -16) //accuracy of Double
    
    var a = xStart
    var b = xStart + pow(10, -15)
    
    var i = 0
    
    while abs(a - b) > e {
        
        if f(a) == f(b) {
            
            throw RegulaFalsiError.horizontalSecant
        }
        
        let aAlt = a
        a = aAlt - f(aAlt) * ((b - aAlt) / (f(b) - f(aAlt)))
        b = aAlt
        
        i += 1
        
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
