//
//  MeasurementView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI
import AVFoundation

struct MeasurementView: View {
    
    let completionHandler: (Measurement) -> Void // wird ausgeführt, wenn gemessen wurde
    @ObservedObject var alignmentManager = AlignmentManager() // Objekt zum Messen von Azimut und Elevation
    
    let relation = UIScreen.main.bounds.height / UIScreen.main.bounds.width
    
    @State var isSunCentered = false // ob die Sonne mittig ausgerichtet ist
    
    var body: some View {
        
        ZStack {
        
            VStack {
                
                Spacer()
                
                CameraView(sunIsCentered)
                    .frame(width: 300, height: 300 * relation, alignment: .center)
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
                
                Spacer()
            }
        }
    }
    
    func sunIsCentered(withData measurement: Measurement) { // Wenn der Messen-Button gedrückt wurde, oder wenn das neuronale Netz die Sonne in der Mitte erkannt hat (noch nicht implementiert)...
        
        isSunCentered = true
        
        let systemSound: SystemSoundID = 1407
        AudioServicesPlaySystemSound(systemSound)
        
        let delayingQueue = DispatchQueue(label: "com.timjaeger.delayingQueue", qos: .userInitiated)
        
        delayingQueue.async {
            
            sleep(1)
            
            completionHandler(measurement) // Messdaten werden übertragen.
        }
    }
}

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementView(completionHandler: {(a: Measurement) -> Void in })
    }
}
