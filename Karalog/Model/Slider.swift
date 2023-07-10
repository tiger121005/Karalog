//
//  Slider.swift
//  Karalog
//
//  Created by 伊藤汰海 on 2023/06/17.
//

import UIKit

class Slider: UISlider {
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let tapPoint = touch.location(in: self)
        let fraction = Float(tapPoint.x / bounds.width)
        let newValue = (maximumValue - minimumValue) * fraction + minimumValue
        if round(newValue) != value {
            value = round(newValue)
        }
        return true
    }
    
}
