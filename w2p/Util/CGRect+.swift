//
//  CGRect+.swift
//  w2p
//
//  Created by vas on 10.03.2021.
//

import UIKit


extension CGRect {
    
    var center: CGPoint {
        CGPoint(x: origin.x + size.width / 2, y: origin.y + size.height / 2)
    }
    
    
}
