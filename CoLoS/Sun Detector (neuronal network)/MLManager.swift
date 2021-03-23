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
import UIKit
import CoreImage

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
            
            logger.debug("MLManager: Smartphone is held still by the user.")
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let croppedImage = ciImage.cropped(to: CGRect(x: (ciImage.extent.width / 2.0) - (ciImage.extent.height / 2.0), y: 0, width: ciImage.extent.height, height: ciImage.extent.height))
            let image = croppedImage.oriented(.rightMirrored)
            
//            var buffer: CVPixelBuffer?
//            let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//
//            CVPixelBufferCreate(kCFAllocatorDefault, Int(image.extent.width), Int(image.extent.height), kCVPixelFormatType_32BGRA, attributes, &buffer)
//            let context = CIContext()
//            context.render(image, to: buffer!)
            
            let buffer = pixelBufferFromImage(image)
            
            guard let resizedPixelBuffer = resizePixelBuffer(buffer, width: 224, height: 224) else {
                
                logger.error("MLManager: Could not resize pixelBuffer.")
                
                return
            }
            
            guard let result = predictSun(in: resizedPixelBuffer) else { return }
            
            let sunPixels = getSun(in: result)
            
            delegate.mlManagerDetectedSun(sunPixels)

            delegate.mlManagerDetectedSunCenter(getCenter(of: sunPixels), withMeasurement: measurement)
        }
        
        referenceImage = pixelBuffer
    }
    
    private func pixelBufferFromImage(_ ciimage: CIImage) -> CVPixelBuffer { //Methode wurde nicht von uns geschrieben (Quelle: https://gist.github.com/omarojo/b47ad0f0965ba8bf2e825ef571ef804c)
        
        //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
        let tmpcontext = CIContext(options: nil)
        let cgimage =  tmpcontext.createCGImage(ciimage, from: ciimage.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
        
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
       
        let width = cgimage!.width
        let height = cgimage!.height
     
        var pxbuffer: CVPixelBuffer?
        // if pxbuffer = nil, you will get status = -6661
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
        status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);

        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
//        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
        

        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
        status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        return pxbuffer!;
        
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
    
    private func predictSun(in image: CVPixelBuffer) -> MLMultiArray! { // Sonne wird erkannt
        
        do {
            
            let neuralNetwork = SunDetector() // Instanz des neuronalen Netzes
            
            let input = SunDetectorInput(input_1: image)
            
            let output = try neuralNetwork.prediction(input: input)
            
            return output.Identity
        }
        catch {
            
            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
            
            return nil
        }
    }
    
    private func getSun(in multiArray: MLMultiArray) -> [CGPoint] { // Gibt die Region der Sonne aus einer gegebenen Maske an
        
        var sunPixels: [CGPoint] = []
                
        for x in 0 ..< 224 {
            
            for y in 0 ..< 224 {
                
                let value = multiArray[[0, x, y] as [NSNumber]].floatValue
                
                if value >= 0.5 {
                    
                    sunPixels.append(CGPoint(x: x, y: y))
                }
            }
        }
        
        return sunPixels
    }
    
    private func getCenter(of points: [CGPoint]) -> CGPoint {
        
        var center = CGPoint.zero
        
        for point in points {
            
            center.x += point.x
            center.y += point.y
        }
        
        center.x = center.x / CGFloat(points.count)
        center.y = center.y / CGFloat(points.count)
        
        return center
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
    
//    private func getMLMultiArray(from pixelBuffer: CVPixelBuffer) -> MLMultiArray! { // wandelt einen PixelBuffer in eine 1 x <width> x <height> x 3 Matrix um
//
//        do {
//
//            // Maße des PixelBuffers werden ermittelt
//
//            let width = CVPixelBufferGetWidth(pixelBuffer)
//            let height = CVPixelBufferGetWidth(pixelBuffer)
//
//            // Matrix wird initialisiert
//
//            let array = try MLMultiArray(shape: [1, width, height, 3] as [NSNumber], dataType: .float32)
//
//            // auslesen der Bytes und übertragen in die Matrix / vgl. https://stackoverflow.com/questions/34569750/get-pixel-value-from-cvpixelbufferref-in-swift
//            // noch nicht fertig / getestet!!!
//
//            CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
//
//            let baseAdress = CVPixelBufferGetBaseAddress(pixelBuffer)
//            guard let buffer = baseAdress?.assumingMemoryBound(to: UInt8.self) else {
//
//                logger.error("MLManager: Could not unwrap the baseAdress of the pixelBuffer.")
//                return nil
//            }
//
//            let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
//
//
//            for x in 0 ..< width {
//
//                for y in 0 ..< height {
//
//                    let index = x * 4 + y * bytesPerRow
//
//                    array[[0, x, y, 0] as [NSNumber]] = NSNumber(value: buffer[index + 2])
//                    array[[0, x, y, 1] as [NSNumber]] = NSNumber(value: buffer[index + 1])
//                    array[[0, x, y, 2] as [NSNumber]] = NSNumber(value: buffer[index])
//                }
//            }
//
//            return array
//        }
//        catch {
//
//            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
//            return nil
//        }
//    }
}

protocol MLManagerDelegate {
    
    func mlManagerDetectedSunCenter(_ center: CGPoint, withMeasurement measurement: Measurement)
    
    func mlManagerDetectedSun(_ points: [CGPoint])
}
