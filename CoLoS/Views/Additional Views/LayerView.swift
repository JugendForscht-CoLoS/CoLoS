//
//  LayerView.swift
//  CoLoS
//
//  Created by Tim Jaeger on 12.03.21.
//

import Foundation
import UIKit

class LayerView: UIView {
    
    override var frame: CGRect {
        
        didSet {
            
            if let sublayers = super.layer.sublayers {
                
                for sublayer in sublayers {
                    
                    sublayer.frame = super.frame
                }
            }
        }
    }
}
