//
//  Angle.swift
//  CoLoS
//
//  Created by Tim Jaeger on 13.01.21.
//

import Foundation

func smallAngle(_ alpha: Double) -> Double {
    
    if alpha >= 2 * Double.pi {
        
        return alpha - 2 * Double.pi
    }
    else if alpha < 0 {
        
        return smallAngle(alpha + 2 * Double.pi)
    }
    else {
        
        return alpha
    }
}

func toRadians(_ degrees: Double) -> Double {
    
    return (Double.pi / 180.0) * degrees
}

func toDegrees(_ radians: Double) -> Double {
    
    return (180.0 / Double.pi) * radians
}
