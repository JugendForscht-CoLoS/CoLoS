//
//  MapView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import MapKit
import SwiftUI

final class MapView: NSObject, UIViewRepresentable {
    
    let location: ComputedLocation
    let mapView: MKMapView
    var tileRenderer: MKTileOverlayRenderer! = nil
    
    init(_ location: ComputedLocation) {
        
        self.location = location
        mapView = MKMapView()
        
        super.init()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        let overlay = OSMTileOverlay()
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
        mapView.delegate = self
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(Annotation(coordinate: location.coordinate))
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        
    }
}

extension MapView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        return tileRenderer
    }
}

class OSMTileOverlay: MKTileOverlay {
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        
        if path.z <= 5 {
            
            let fileManager = FileManager.default
            
            if var url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                
                url.appendPathComponent("map")
                url.appendPathComponent("\(path.z)")
                url.appendPathComponent("\(path.x)")
                url.appendPathComponent("\(path.y).png")
                
                if fileManager.fileExists(atPath: url.path) {
                    
                    return url
                }
                else {
                    
                    return Bundle.main.url(forResource: "default", withExtension: "png")!
                }
            }
            else {
                
                return Bundle.main.url(forResource: "default", withExtension: "png")!
            }
        }
        else {
            
            return Bundle.main.url(forResource: "default", withExtension: "png")!
        }
    }
}

class Annotation: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        
        self.coordinate = coordinate
        title = "berechneter Standort"
        subtitle = "\(coordinate.latitude)°, \(coordinate.longitude)°"
    }
}
