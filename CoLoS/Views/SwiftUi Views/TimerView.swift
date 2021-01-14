//
//  TimerView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI

struct TimerView: View {
    
    let completionHandler: () -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var remainingSec = 300.0 // 5 min
    
    var body: some View {
        
        VStack {
            
            ProgressView("verbleibende Zeit", value: (300.0 - remainingSec), total: 300.0)
                .padding()
                .onReceive(timer) { _ in
                        
                    if self.remainingSec > 0 {
                            
                        self.remainingSec -= 1
                    }
                    else if self.remainingSec == 0 {
                            
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
