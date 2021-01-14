//
//  ComputedLocation.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreLocation

struct ComputedLocation {
    
    init(_ radiansCoordinate: RadiansCoordinate) {
        
        coordinate = CLLocationCoordinate2D(latitude: toDegrees(radiansCoordinate.latitude), longitude: toDegrees(radiansCoordinate.longitude))
    }
    
    let coordinate: CLLocationCoordinate2D
}

typealias RadiansCoordinate = CLLocationCoordinate2D
