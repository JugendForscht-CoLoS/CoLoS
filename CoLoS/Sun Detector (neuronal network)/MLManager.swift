//
//  MLManager.swift
//  CoLoS
//
//  Created by Tim Jaeger on 12.01.21.
//

import Foundation
import CoreGraphics
import CoreVideo
import CoreML
import Vision
import AVFoundation

class MLManager: NSObject {
    
    var delegate: MLManagerDelegate
    
    let accuracy: CGFloat = 5.0
    
    private let sequenceRequestHandler = VNSequenceRequestHandler()
    
    private var referenceImage: CVPixelBuffer?
    private var transpositionHistory: [CGPoint] = []
    private let maximumhistoryLength = 30
    
    init(delegate: MLManagerDelegate) {
        
        self.delegate = delegate
        super.init()
    }
    
    func addNewImage(_ pixelBuffer: CVPixelBuffer, withMeasurement measurement: Measurement) { // fügt ein neues Bild hinzu
        
        guard referenceImage != nil else {
            
            referenceImage = pixelBuffer
            return
        }
        
        let registrationRequest = VNTranslationalImageRegistrationRequest(targetedCVPixelBuffer: pixelBuffer, completionHandler: requestHasFinishedExecuting)
        
        do {
            
            try sequenceRequestHandler.perform([registrationRequest], on: referenceImage!)
        }
        catch {
            
            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
        }
        
        if sceneStabilityArchieved() { // Wenn das Smartphone still gehalten wird
            
            guard let resizedPixelBuffer = resizePixelBuffer(pixelBuffer, width: 224, height: 224) else {
                
                logger.error("MLManager: Could not resize pixelBuffer.")
                
                return
            }
        
            guard let multiArray = getMLMultiArray(from: resizedPixelBuffer) else { return }
            
            guard let result = predictSun(of: multiArray) else { return }

            delegate.mlManagerDetectedSun(getSunCentre(in: result), withMeasurement: measurement)
        }
        
        referenceImage = pixelBuffer
    }
    
    private func sceneStabilityArchieved() -> Bool {
        
        if transpositionHistory.count == maximumhistoryLength {
            
            var movingAverage = CGPoint.zero
            
            for point in transpositionHistory {
                
                movingAverage.x += point.x
                movingAverage.y += point.y
            }
            
            let distance = sqrt(movingAverage.x * movingAverage.x + movingAverage.y * movingAverage.y)
            
            if distance < accuracy {
                
                return true
            }
        }
        
        return false
    }
    
    private func getMLMultiArray(from pixelBuffer: CVPixelBuffer) -> MLMultiArray! { // wandelt einen PixelBuffer in eine 1 x <width> x <height> x 3 Matrix um
        
        do {
            
            // Maße des PixelBuffers werden ermittelt
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetWidth(pixelBuffer)
            
            // Matrix wird initialisiert
            
            let array = try MLMultiArray(shape: [1, width, height, 3] as [NSNumber], dataType: .float32)
            
            // auslesen der Bytes und übertragen in die Matrix / vgl. https://stackoverflow.com/questions/34569750/get-pixel-value-from-cvpixelbufferref-in-swift
            // noch nicht fertig / getestet!!!
            
            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
            
            let baseAdress = CVPixelBufferGetBaseAddress(pixelBuffer)
            guard let buffer = baseAdress?.assumingMemoryBound(to: UInt8.self) else {
                
                logger.error("MLManager: Could not unwrap the baseAdress of the pixelBuffer.")
                return nil
            }
            
            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
            
            
            for x in 0 ..< width {
                
                for y in 0 ..< height {
                    
                    let index = x * 4 + y * bytesPerRow
                    
                    array[[0, x, y, 0] as [NSNumber]] = NSNumber(value: buffer[index + 2])
                    array[[0, x, y, 1] as [NSNumber]] = NSNumber(value: buffer[index + 1])
                    array[[0, x, y, 2] as [NSNumber]] = NSNumber(value: buffer[index])
                }
            }
            
            return array
        }
        catch {
            
            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    private func predictSun(of multiArray: MLMultiArray) -> MLMultiArray! { // Sonne wird erkannt
        
        do {
            
            let neuralNetwork = SunDetector() // Instanz des neuronalen Netzes
            
            let input = SunDetectorInput(input_1: multiArray)
            
            let output = try neuralNetwork.prediction(input: input)
            
            return output.Identity
        }
        catch {
            
            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
            
            return nil
        }
    }
    
    private func getSunCentre(in multiArray: MLMultiArray) -> CGPoint { // Gibt die Region der Sonne aus einer gegebenen Maske an
        
        //ToDo
        return CGPoint.zero
    }
    
    private func requestHasFinishedExecuting(request: VNRequest, error: Error?) {
        
        if let error = error {
            
            logger.error("MLManager: An error occured \(error.localizedDescription, privacy: .public)")
        }
        
        guard let results = request.results else { return }
        
        guard let alignmentObservation = results.first as? VNImageTranslationAlignmentObservation else { return }
        
        let alignmentTransform = alignmentObservation.alignmentTransform
        
        transpositionHistory.append(CGPoint(x: alignmentTransform.tx, y: alignmentTransform.ty))
        
        if transpositionHistory.count > maximumhistoryLength {
            
            transpositionHistory.removeFirst()
        }
    }
}

protocol MLManagerDelegate {
    
    func mlManagerDetectedSun(_ centre: CGPoint, withMeasurement measurement: Measurement)
}
