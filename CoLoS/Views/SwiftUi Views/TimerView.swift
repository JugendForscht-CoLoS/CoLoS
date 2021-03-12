//
//  TimerView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI
import AVFoundation

struct TimerView: View {
    
    let completionHandler: () -> Void // wird ausgeführt, wenn die Wartezeit abgelaufen ist
    
    let timeIntervall = 3600.0
    let endTime: Double
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var remainingSec = 3600.0 // Wartezeit (1h)
    
    init(completionHandler: @escaping () -> Void) {
        
        self.completionHandler = completionHandler
        
        endTime = Double(Date().timeInSec) + timeIntervall
    }
    
    var body: some View {
        
        VStack {
            
            ProgressView("verbleibende Zeit", value: (3600.0 - remainingSec), total: 3600.0)
                .padding()
                .onReceive(timer) { _ in // wird jede Sekunde ausgeführt
                        
                    if self.remainingSec > 0 { // Wenn die Zeit noch läuft...
                            
                        self.remainingSec = endTime - Double(Date().timeInSec)
                    }
                    else if self.remainingSec == 0 { // Wenn die Zeit abgelaufen ist...
                            
                        let systemSound: SystemSoundID = 1304
                        AudioServicesPlaySystemSound(systemSound)
                        self.completionHandler()
                    }
                }
            
            Text("\(Int(remainingSec) / 60):\(Int(remainingSec) % 60)")
                .font(.title)
                .fontWeight(.heavy)
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(completionHandler: {() -> Void in })
    }
}
