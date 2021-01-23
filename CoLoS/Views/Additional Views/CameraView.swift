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
    let completionHandler: () -> Void
    var mlManager: MLManager! = nil
    
    private let view = UIView()
    private var previewLayer: CALayer! = nil
    
    init(_ completionHandler: @escaping () -> Void) {
        
        self.completionHandler = completionHandler
        
        super.init()
        
        mlManager = MLManager(delegate: self)
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            
            logger.fault("CameraView: Could not get connection to the camera.")
            return
        }
        do {
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) {
                
                captureSession.addInput(input)
            }
            else {
                
                logger.fault("CameraView: Could not add camera to capture session.")
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue.main) //Queue!!!
            
            if captureSession.canAddOutput(output) {
                
                captureSession.addOutput(output)
            }
            else {
                
                logger.fault("CameraView: Could not add output to capture session.")
            }
            
            captureSession.startRunning()
        }
        catch {
            
            logger.fault("CameraView: Could not initialize AVCaptureDeviceInput object.")
        }
    }
    
    func makeUIView(context: Context) -> UIView {
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let layer = previewLayer {
            
            layer.frame = view.frame
        }
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        mlManager.addNewImage(pixelBuffer)
    }
}

extension CameraView: MLManagerDelegate {
    
    func mlManagerDetectedSun(inRegion region: CGRect) {
        
        if region.isEmpty { //Hier wird überprüft ob Sonne mittig ist (das ist natürlich noch nicht richtig und dient als Platzhalter)
            
            captureSession.stopRunning()
            completionHandler()
        }
    }
}
