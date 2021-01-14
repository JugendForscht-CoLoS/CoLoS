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
        
       /* if referenceImage == nil {
            
            referenceImage = pixelBuffer
            index = 0
            return
        }
        if index == 3 {
            
            referenceImage = pixelBuffer
        }
        else if !checkForDifference(in: pixelBuffer, and: referenceImage) {
        
            let multiArray = getMLMultiArray(from: pixelBuffer)
            let finalImage = resizeMLMultiArray(multiArray)
            let result = predictSun(of: finalImage)
            delegate.mlManagerDetectedSun(inRegion: getRegionOfSun(in: result))
        }
        
        index += 1*/
    }
    
    /*private func checkForDifference(in pixelBuffer1: CVPixelBuffer, and pixelBuffer2: CVPixelBuffer) -> Bool {
        
        //ToDo
        //look here: https://developer.apple.com/videos/play/wwdc2018/717
    }
    
    private func getMLMultiArray(from pixeBuffer: CVPixelBuffer) -> MLMultiArray {
        
        //ToDo
    }
    
    private func resizeMLMultiArray(_ multiArray: MLMultiArray) -> MLMultiArray {
        
        //ToDo
    }
    
    private func predictSun(of multiArray: MLMultiArray) -> MLMultiArray {
        
        //ToDo
    }
    
    private func getRegionOfSun(in multiArray: MLMultiArray) -> CGRect {
        
        //ToDo
    }*/
}

protocol MLManagerDelegate {
    
    func mlManagerDetectedSun(inRegion region: CGRect)
}
