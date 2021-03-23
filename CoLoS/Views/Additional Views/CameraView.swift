//
//  CameraView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 02.01.21.
//

import Foundation
import SwiftUI
import AVFoundation

final class CameraView: NSObject, UIViewRepresentable {
    
    let captureSession = AVCaptureSession()
    var device: AVCaptureDevice! // Verweis auf die Kamera
    
    let completionHandler: (Measurement) -> Void // wird ausgeführt, wenn das neuronale Netz die Sonne in der Mitte erkannt hat
    let alignmentManager = AlignmentManager()
    
    var mlManager: MLManager! = nil // Onjekt zum Verwenden des neuronalen Netzes
    let mlQueue = DispatchQueue(label: "com.timjaeger.MLQueue", qos: .utility, attributes: .concurrent)
    
    private let view = LayerView()
    private var previewLayer: CALayer! = nil
    
    init(_ completionHandler: @escaping (Measurement) -> Void) {
        
        self.completionHandler = completionHandler
        
        super.init()
        
        mlManager = MLManager(delegate: self)
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            
            logger.fault("CameraView: Could not get connection to the camera.")
            return
        }
        
        self.device = device
        
        do {
            
            try device.lockForConfiguration() //Ermöglicht Veränderung des ISO-Werts und der Belichtungszeit (erleichtert Sonnenerkennung).
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) { // Kamera-Input wird hinzugefügt.
                
                captureSession.addInput(input)
            }
            else {
                
                logger.fault("CameraView: Could not add camera to capture session.")
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: mlQueue)
            
            if captureSession.canAddOutput(output) { // Kamera-Output wird hinzugefügt.
                
                captureSession.addOutput(output)
            }
            else {
                
                logger.fault("CameraView: Could not add output to capture session.")
            }
            
            captureSession.startRunning()
        }
        catch {
            
            logger.fault("CameraView: An error occured \(error.localizedDescription, privacy: .public)")
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) // Kamera-Bild wird zu der View hinzugefügt.
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) { // wird immer dann aufgerufen, wenn die Kamera ein neues Bild aufgenommen hat (mehrmals pro Sekunde)
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)! // PixelBuffer wird erstellt
        
        let date = Date()
        
        let dateInSec = date.dateInSec
        let timeUTC = date.timeInSec
        
        let measurement = Measurement(azimut: alignmentManager.azimut, elevation: alignmentManager.elevation, date: dateInSec, time: timeUTC)
        
        mlManager.addNewImage(pixelBuffer, withMeasurement: measurement) // Das Bild wird an das neuronale Netz übergeben.
    }
}

extension CameraView: MLManagerDelegate {
    
    func mlManagerDetectedSunCenter(_ center: CGPoint, withMeasurement measurement: Measurement) { // wird immer dann ausgeführt, wenn das neuronale Netz die Sonne erkannt hat
        
        logger.debug("CameraView: Detected center of sun: (\(center.x) | \(center.y))")
        
        let imageCenter = CGPoint(x: 112, y: 112)
        
        let distance = sqrt((imageCenter.x - center.x) * (imageCenter.x - center.x) + (imageCenter.y - center.y) * (imageCenter.y - center.y))
        
        if distance < mlManager.accuracy {
            
            completionHandler(measurement)
            captureSession.stopRunning()
        }
    }
    
    func mlManagerDetectedSun(_ points: [CGPoint]) {
        
        logger.debug("CameraView: Detected \(points.count) sun pixels!")
    }
}
