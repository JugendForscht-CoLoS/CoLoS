//
//  AlignmentManager.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreMotion

class AlignmentManager: ObservableObject {
    
    let manager: CMMotionManager // Objekt, welches die Sensoren auslesen kann
    
    var elevation = 0.0
    var azimut = 0.0
    
    @Published var isPositionRight = false
    
    init() {
        
        manager = CMMotionManager()
        
        if manager.isDeviceMotionAvailable { // überprüft, ob Sensoren verfügbar sind
            
            let measurementQueue = OperationQueue()
            measurementQueue.name = "com.timjaeger.measurementQueue"
            
            manager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xMagneticNorthZVertical, to: measurementQueue, withHandler: deviceMotionHasUpdated) // Sensorwerte werden nun ausgelesen.
        }
        else {
            
            logger.fault("AlignmentManager: DeviceMotion is not avaidable.")
        }
    }
    
    func deviceMotionHasUpdated(data: CMDeviceMotion?, error: Error?) { // wird ausgeführt, sobalt neue Werte verfügbar sind
        
        if let data = data {
            
            // Berechnung des Azimuts und der Elevation
            
            elevation = (Double.pi / 2.0) - data.attitude.pitch
            
            let magneticField = Vector(x: data.magneticField.field.x, y: data.magneticField.field.y, z: data.magneticField.field.z)
            
            let paraB = -1 * cos(elevation) * magneticField.y + sin(elevation) * magneticField.z
            let paraR = -1 * sin(elevation)
            
            let projectedB = magneticField + paraB * Vector(x: 0, y: cos(elevation), z: -1 * sin(elevation))
            let projectedR = Vector(x: 0, y: 0, z: -1) + paraR * Vector(x: 0, y: cos(elevation), z: -1 * sin(elevation))
            
            let angle = projectedB ^ projectedR
            
            if magneticField.x < 0 {
                
                azimut = angle
            }
            else {
                
                azimut = 2 * Double.pi - angle
            }
        }
        else {
            
            logger.fault("AlignmentManager: Could not unwrap CMDeviceMotion data.")
        }
        if let error = error {
            
            logger.error("AlignmentManager: An Error occured in deviceMotionHasUpdated() \(error.localizedDescription, privacy: .public)")
        }
    }
}
