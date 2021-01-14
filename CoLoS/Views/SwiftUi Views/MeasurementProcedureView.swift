//
//  MeasurementProceedView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 03.01.21.
//

import SwiftUI
import CoreLocation

struct MeasurementProcedureView: View {
    
    @State var viewType = MeasurementTypes.measurementView
    @State var firstMeasurement = true
    @State var location = ComputedLocation( CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    let manager = CoLoSManager()
    
    var body: some View {
        
        if viewType == .measurementView {
            
            MeasurementView(completionHandler: measurementCompleted)
                .navigationTitle("Sonnen-Messung")
                .navigationBarBackButtonHidden(true)
        }
        if viewType == .timerView {
            
            TimerView(completionHandler: timerStoped)
                .navigationTitle("Wartezeit")
                .navigationBarBackButtonHidden(true)
        }
        if viewType == .locationView {
            
            LocationView(location: location)
                .navigationTitle("Standort")
                .navigationBarBackButtonHidden(false)
        }
    }
    
    func timerStoped() {
        
        viewType = .measurementView
    }
    
    func measurementCompleted(azimut: Double, elevation: Double, time: Double, date: Double) {
        
        DispatchQueue.main.async {
            
            if firstMeasurement {
                
                viewType = .timerView
                firstMeasurement = false
                
                manager.addFirstMeasurement(azimut: azimut, elevation: elevation, time: time, date: date)
            }
            else {
                
                manager.addSecondMeasurement(azimut: azimut, elevation: elevation)
                location = manager.computeUsersLocation()
                viewType = .locationView
            }
        }
    }
}

struct MeasurementProceedView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementProcedureView()
    }
}

enum MeasurementTypes {
    
    case measurementView
    case timerView
    case locationView
}
