//
//  OrientationResolver.swift
//  w2p
//
//  Created by vas on 28.03.2021.
//

import UIKit

class OrientationResolver {
    
    static var allowToChangeOrientation = false
    static var orientationMask: UIInterfaceOrientationMask {
        if allowToChangeOrientation {
            return .allButUpsideDown
        } else {
            return .portrait
        }
    }

}
