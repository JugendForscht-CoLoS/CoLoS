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
    
    let location: ComputedLocation? // repräsentiert den zu markierenden Standort
    let mapView: MKMapView // Map-Objekt
    var tileRenderer: MKTileOverlayRenderer! = nil // Objekt zum Erstellen der Offline-Map aus den geladenen Map-Tiles
    
    init(_ location: ComputedLocation?) {
        
        self.location = location
        mapView = MKMapView()
        
        super.init()
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.isRotateEnabled = false
        
        let overlay = OSMTileOverlay() // Offline-Map-Tiles
        overlay.canReplaceMapContent = true
        mapView.addOverlay(overlay, level: .aboveLabels)
        tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
        mapView.delegate = self
        
        if let location = location {
            
            // Annotation wird erstellt und die Karte ausgerichtet.
            
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(Annotation(coordinate: location.coordinate))
        }
        
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
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL { // lädt die Map-Tiles
        
        if path.z <= 5 { // Es wurden nur Map-Tiles für z <= 5 geladen.
            
            let fileManager = FileManager.default // Objekt zum Verwalten des Dateisystems
            
            if var url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first { // Url vom Cache-Verzeichnis
                
                // Pfad wird erstellt
                
                url.appendPathComponent("map")
                url.appendPathComponent("\(path.z)")
                url.appendPathComponent("\(path.x)")
                url.appendPathComponent("\(path.y).png")
                
                if fileManager.fileExists(atPath: url.path) { // Wenn das Map-Tile existiert...
                    
                    return url
                }
                else {
                    
                    logger.info("OSMTileOverlay: MapTiles have not been downloaded yet.")
                    return Bundle.main.url(forResource: "default", withExtension: "png")!
                }
            }
            else {
                
                logger.error("OSMTileOverlay: Could not find cache url.")
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
