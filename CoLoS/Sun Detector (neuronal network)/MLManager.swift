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

class MLManager {
    
    var delegate: MLManagerDelegate
    
    private var referenceImage: CVPixelBuffer! = nil
    private var index = 0
    
    let size: (Int, Int) = (128, 128)
    
    init(delegate: MLManagerDelegate) {
        
        self.delegate = delegate
    }
    
    func addNewImage(_ pixelBuffer: CVPixelBuffer) {
        
       if referenceImage == nil {
            
            referenceImage = pixelBuffer
            index = 0
            return
        }
        if index == 3 {
            
            referenceImage = pixelBuffer
        }
        else if !checkForDifference(in: pixelBuffer, and: referenceImage) {
        
            guard let multiArray = getMLMultiArray(from: pixelBuffer) else { return }
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetWidth(pixelBuffer)
            
            guard let finalImage = resizeMLMultiArray(multiArray, width: width, height: height) else { return }
            
            guard let result = predictSun(of: finalImage) else { return }
            
            delegate.mlManagerDetectedSun(inRegion: getRegionOfSun(in: result))
        }
        
        index += 1
    }
    
    private func checkForDifference(in pixelBuffer1: CVPixelBuffer, and pixelBuffer2: CVPixelBuffer) -> Bool {
        
        //ToDo
        //look here: https://developer.apple.com/videos/play/wwdc2018/717
        
        return true
    }
    
    private func getMLMultiArray(from pixelBuffer: CVPixelBuffer) -> MLMultiArray! {
        
        do {
            
            let width = CVPixelBufferGetWidth(pixelBuffer)
            let height = CVPixelBufferGetWidth(pixelBuffer)
            
            let array = try MLMultiArray(shape: [1, width, height, 3] as [NSNumber], dataType: .float32)
            
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
    
    private func resizeMLMultiArray(_ multiArray: MLMultiArray, width: Int, height: Int) -> MLMultiArray! {
        
        let size = min(width, height)
        
        do {
            
            let resizedArray = try MLMultiArray(shape: [1, size, size, 3] as [NSNumber], dataType: .float32)
            
            var x1 = 0
            var y1 = 0
            
            for x in ((width - size) / 2) - 1 ..< size + ((width - size) / 2) {
                
                for y in ((height - size) / 2) - 1 ..< size + ((height - size) / 2) {
                    
                    resizedArray[[0, x1, y1, 0] as [NSNumber]] = multiArray[[1, x, y, 0] as [NSNumber]]
                    resizedArray[[0, x1, y1, 1] as [NSNumber]] = multiArray[[1, x, y, 1] as [NSNumber]]
                    resizedArray[[0, x1, y1, 2] as [NSNumber]] = multiArray[[1, x, y, 2] as [NSNumber]]
                    
                    y1 += 1
                }
                
                x1 += 1
            }
            
            let resizeFactor = (224.0 / Double(size))
            
            let finalArray = try MLMultiArray(shape: [1, 224, 224, 3] as [NSNumber], dataType: .float32)
            
            //ToDo
            
            return finalArray
        }
        catch {
            
            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    private func predictSun(of multiArray: MLMultiArray) -> MLMultiArray! {
        
        do {
            
            let neuralNetwork = SunDetector()
            
            let input = SunDetectorInput(input_1: multiArray)
            
            let output = try neuralNetwork.prediction(input: input)
            
            return output.Identity //ToDo
        }
        catch {
            
            logger.error("MLManager: An error occured: \(error.localizedDescription, privacy: .public)")
            
            return nil
        }
    }
    
    private func getRegionOfSun(in multiArray: MLMultiArray) -> CGRect {
        
        //ToDo
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}

protocol MLManagerDelegate {
    
    func mlManagerDetectedSun(inRegion region: CGRect)
}
