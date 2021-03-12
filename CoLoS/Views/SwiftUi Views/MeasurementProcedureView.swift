//
//  MeasurementProcedureView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 03.01.21.
//

import SwiftUI
import CoreLocation

struct MeasurementProcedureView: View {
    
    static var taskID = UUID()
    
    @State var viewType = MeasurementTypes.measurementView // zeigt die aktuelle View an
    @State var firstMeasurement = true // zeigt an, ob es die erste Messung oder die Zweite ist
    @State var location: ComputedLocation! = nil // der berechnete Standort
    
    let manager = CoLoSManager() // Objekt zum Berechnen des Standorts
    
    var body: some View {
        
        if viewType == .measurementView { // Beim Messen...
            
            MeasurementView(completionHandler: measurementCompleted)
                .navigationTitle("Sonnen-Messung")
                .navigationBarBackButtonHidden(true)
        }
        if viewType == .timerView { // Beim Warte...
            
            TimerView(completionHandler: timerStoped)
                .navigationTitle("Wartezeit")
                .navigationBarBackButtonHidden(true)
        }
        if viewType == .locationView { // Wenn der Standort berechnet wurde...
            
            LocationView(location: location)
                .navigationTitle("Standort")
                .navigationBarBackButtonHidden(false)
        }
    }
    
    func timerStoped() { // Wenn die Wartezeit abgelaufen ist
        
        viewType = .measurementView // die View wird auf MeasurementView gewechselt
    }
    
    func measurementCompleted(_ measurement: Measurement) { // Wenn gemessen wurde...
        
        DispatchQueue.main.async {
            
            if firstMeasurement { // erste Messung
                
                MeasurementProcedureView.taskID = UUID() // taskID ist nur für das Logging interessant
                
                viewType = .timerView // die View wird auf TimerView gewechselt
                firstMeasurement = false
                
                manager.addFirstMeasurement(measurement) // Messdaten werden gespeichert
                logger.notice("Measurement1(\(MeasurementProcedureView.taskID, privacy: .public)): azimut = \(toDegrees(measurement.azimut))°; elevation = \(toDegrees(measurement.elevation))°; time = \(measurement.time)s; date = \(measurement.date)s")
            }
            else { // zweite Messung
                
                manager.addSecondMeasurement(measurement) // Messdaten werden gespeichert
                logger.notice("Measurement2(\(MeasurementProcedureView.taskID, privacy: .public)): azimut = \(toDegrees(measurement.azimut))°; elevation = \(toDegrees(measurement.elevation))°; time = \(measurement.time)s; date = \(measurement.date)s")
                
                location = manager.computeUsersLocation() // Standort wird berechnet
                viewType = .locationView // die View wird auf TimerView gewechselt
            }
        }
    }
}

struct MeasurementProcedureView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementProcedureView()
    }
}

enum MeasurementTypes { // Arten von Views
    
    case measurementView
    case timerView
    case locationView
}
