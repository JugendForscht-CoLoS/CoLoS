//
//  MeasurementView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI
import AVFoundation

struct MeasurementView: View {
    
    let completionHandler: (Double, Double, Double, Double) -> Void
    let alignmentManager = AlignmentManager()
    
    let realation = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    
    @State var isSunCentered = false
    
    var body: some View {
        
        ZStack {
        
            VStack {
                
                Spacer()
                
                CameraView(sunIsCentered)
                    .frame(width: 300, height: 300 * realation, alignment: .center)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 7)
                
                Spacer()
                
                Spacer()
                
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
            
            VStack {
                
                Spacer()
                
                Spacer()
                
                Spacer()
                
                Spacer()
                
                Text(isSunCentered ? "Sonne ist mittig" : "Sonne zentrieren")
                    .font(.headline)
                    .foregroundColor(isSunCentered ? Color.green : Color.red)
                
                Button("messen", action: sunIsCentered)
                    .padding()
                
                Spacer()
            }
        }
    }
    
    func sunIsCentered() {
        
        let dateObj = Date()
        let date = Double(dateObj.dateInSec)
        let timeUTC = Double(dateObj.timeInSec)
        
        let elevation = alignmentManager.elevation
        let azimut = alignmentManager.azimut
        
        isSunCentered = true
        
        let systemSound: SystemSoundID = 1407
        AudioServicesPlaySystemSound(systemSound)
        
        let delayingQueue = DispatchQueue(label: "com.timjaeger.delayingQueue", qos: .userInitiated)
        
        delayingQueue.async {
            
            sleep(1)
            
            completionHandler(azimut, elevation, date, timeUTC)
        }
    }
}

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementView(completionHandler: {(a: Double, b: Double, c: Double, d: Double) -> Void in })
    }
}
