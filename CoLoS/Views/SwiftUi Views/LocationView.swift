//
//  LocationView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI
import CoreLocation

struct LocationView: View {
    
    let location: ComputedLocation
    
    var body: some View {
        
        MapView(location)
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(location: ComputedLocation(RadiansCoordinate(latitude: toRadians(49.763), longitude: toRadians(8.633))))
    }
}
