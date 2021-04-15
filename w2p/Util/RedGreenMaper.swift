//
//  RedGreenMaper.swift
//  w2p
//
//  Created by vas on 10.03.2021.
//

import UIKit

class RedGreenMaper {
    
    var minValue: Double
    var maxValue: Double

    init(minValue: Double, maxValue: Double) {
        self.minValue = minValue
        self.maxValue = maxValue
    }
    
    func mapToColor(value: Double) -> UIColor? {
        let percentage = value / (maxValue - minValue)
        return UIColor(hue: CGFloat(percentage) * (1/3), saturation: 1, brightness: 1, alpha: 1)
    }
}
