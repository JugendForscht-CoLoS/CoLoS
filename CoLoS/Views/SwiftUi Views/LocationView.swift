//
//  LocationView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI
import CoreLocation

struct LocationView: View {
    
    var location: ComputedLocation? // Standort
    @State var wasNotSuccessful: Bool = false // zeigt an, ob die Standortsbestimmung ein valides Ergebnis ergeben hat
    
    init(location: ComputedLocation) {
        
        self.location = location
        
        if !(location.coordinate.latitude >= -90 && location.coordinate.latitude <= 90) { // Wenn der Breitengrad falsch ist...
            
            self.location = nil
            _wasNotSuccessful = State(initialValue: true)
            logger.fault("LocationView(\(MeasurementProcedureView.taskID, privacy: .public)): Latitude out of bounds.")
        }
        if !(location.coordinate.longitude >= -180 && location.coordinate.longitude <= 180) { // Wenn der Längengrad falsch ist...
            
            self.location = nil
            _wasNotSuccessful = State(initialValue: true)
            logger.fault("LocationView(\(MeasurementProcedureView.taskID, privacy: .public)): Longitude out of bounds.")
        }
    }
    
    var body: some View {

        MapView(location)
            .cornerRadius(3.0)
            .padding()
            .alert(isPresented: $wasNotSuccessful) {
                    
                Alert(title: Text("Fehler"), message: Text("Standortsbestimmung fehlgeschlagen."), dismissButton: .default(Text("OK")))
            }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(location: ComputedLocation(RadiansCoordinate(latitude: toRadians(49.763), longitude: toRadians(8.633))))
    }
}
