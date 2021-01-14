//
//  ContentView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import SwiftUI

struct ContentView: View {
    
    @State var isWarningShowing = true

    
    var body: some View {
        
        NavigationView {
        
            VStack {
            
                Spacer()
                
                Image("logo")
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                
                Spacer()
            
                NavigationLink(destination: MeasurementProcedureView()) {
                
                    Text("Standort berechnen")
                        .padding()
                        .foregroundColor(.white)
                        .font(.headline)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            
                Spacer()
            }
            
            .navigationTitle("CoLoS")
        }
        .alert(isPresented: $isWarningShowing) {
            
            Alert(title: Text("Achtung"), message: Text("Vermeiden Sie beim Messen in die Sonne zu schauen! Dies kann zu erheblichen Augenschäden führen."), dismissButton: .default(Text("OK")))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
