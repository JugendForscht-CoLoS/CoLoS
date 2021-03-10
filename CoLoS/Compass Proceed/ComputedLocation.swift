//
//  ComputedLocation.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreLocation

struct ComputedLocation {
    
    let coordinate: CLLocationCoordinate2D
    
    // CoLoS arbeitet nur mit Radians; hier wird der Standort, die "ComputedLocation" in Grad° umgerechnet
    init(_ radiansCoordinate: RadiansCoordinate) {
        
        coordinate = CLLocationCoordinate2D(latitude: toDegrees(radiansCoordinate.latitude), longitude: toDegrees(radiansCoordinate.longitude))
    }
    
}

typealias RadiansCoordinate = CLLocationCoordinate2D
