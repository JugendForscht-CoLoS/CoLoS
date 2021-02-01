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
    var device: AVCaptureDevice!
    
    let completionHandler: () -> Void
    
    var mlManager: MLManager! = nil
    let mlQueue = DispatchQueue(label: "com.timjaeger.MLQueue", qos: .utility, attributes: .concurrent)
    
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
        
        self.device = device
        
        do {
            
            try device.lockForConfiguration() //Ermöglicht Veränderung des ISO-Werts und der Belichtungszeit (erleichtert Sonnenerkennung).
            
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) {
                
                captureSession.addInput(input)
            }
            else {
                
                logger.fault("CameraView: Could not add camera to capture session.")
            }
            
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: mlQueue)
            
            if captureSession.canAddOutput(output) {
                
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
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        DispatchQueue.main.async {
        
            if let layer = self.previewLayer {
                
                if layer.frame != self.view.frame {
                        
                    layer.frame = self.view.frame
                }
            }
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
