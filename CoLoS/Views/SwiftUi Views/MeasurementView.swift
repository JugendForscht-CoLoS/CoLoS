//
//  MeasurementView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI
import AVFoundation

struct MeasurementView: View {
    
    let completionHandler: (Double, Double, Double, Double) -> Void // wird ausgeführt, wenn gemessen wurde
    let alignmentManager = AlignmentManager() // Objekt zum Messen von Azimut und Elevation
    
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
                
                Button("messen", action: sunIsCentered)
                    .padding()
                
                Spacer()
            }
        }
    }
    
    func sunIsCentered() { // Wenn der Messen-Button gedrückt wurde, oder wenn das neuronale Netz die Sonne in der Mitte erkannt hat (noch nicht implementiert)...
        
        let dateObj = Date() // Datum
        let date = Double(dateObj.dateInSec) // Datum in Sekunden
        let timeUTC = Double(dateObj.timeInSec) // UTC in Sekunden
        
        let elevation = alignmentManager.elevation
        let azimut = alignmentManager.azimut
        
        isSunCentered = true
        
        let systemSound: SystemSoundID = 1407
        AudioServicesPlaySystemSound(systemSound)
        
        let delayingQueue = DispatchQueue(label: "com.timjaeger.delayingQueue", qos: .userInitiated)
        
        delayingQueue.async {
            
            sleep(1)
            
            completionHandler(azimut, elevation, timeUTC, date) // Messdaten werden übertragen.
        }
    }
}

struct MeasurementView_Previews: PreviewProvider {
    static var previews: some View {
        MeasurementView(completionHandler: {(a: Double, b: Double, c: Double, d: Double) -> Void in })
    }
}
