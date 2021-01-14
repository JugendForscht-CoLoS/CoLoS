//
//  AlignmentManager.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import CoreMotion

class AlignmentManager {
    
    let manager: CMMotionManager
    
    var elevation = 0.0
    var azimut = 0.0
    
    init() {
        
        manager = CMMotionManager()
        
        if manager.isDeviceMotionAvailable {
            
            manager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xMagneticNorthZVertical, to: OperationQueue.main, withHandler: deviceMotionHasUpdated)//Queue!!!!
        }
        else {
            
            //ToDo
        }
    }
    
    func deviceMotionHasUpdated(data: CMDeviceMotion?, error: Error?) {
        
        if let data = data {
            
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
            
            //ToDo
        }
        if let error = error {
            
            //ToDo
        }
    }
}
