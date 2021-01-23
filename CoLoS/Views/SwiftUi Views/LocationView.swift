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
    @State var wasNotSuccessful: Bool = true
    
    init(location: ComputedLocation) {
        
        self.location = location
        
        if location.coordinate.latitude >= -90 || location.coordinate.latitude <= 90 {
            
            if location.coordinate.longitude >= -180 || location.coordinate.longitude <= 180 {
                
                wasNotSuccessful = false
            }
            else {
                
                logger.fault("LocationView(\(MeasurementProcedureView.taskID, privacy: .public)): Longitude out of bounds.")
            }
        }
        else {
            
            logger.fault("LocationView(\(MeasurementProcedureView.taskID, privacy: .public)): Latitude out of bounds.")
        }
    }
    
    var body: some View {
        
        if !wasNotSuccessful {
            
            MapView(location)
        }
        else {
            
            Text("")
                .alert(isPresented: $wasNotSuccessful) {
                    
                    Alert(title: Text("Fehler"), message: Text("Standortsbestimmung fehlgeschlagen."), dismissButton: .default(Text("OK")))
                }
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(location: ComputedLocation(RadiansCoordinate(latitude: toRadians(49.763), longitude: toRadians(8.633))))
    }
}
