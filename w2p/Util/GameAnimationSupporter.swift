//
//  randomAnimation.swift
//  w2p
//
//  Created by vas on 22.03.2021.
//

import UIKit

class GameAnimationSupporter {
    
    static func getRotationAnimation() -> CABasicAnimation {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = CGFloat.pi / 4.5
        rotationAnimation.toValue = -CGFloat.pi / 4.5
        return rotationAnimation
    }
    
    static func getScaleAnimation() -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 0.8
        return scaleAnimation
    }
    
    static func getRandomAnimation() -> CABasicAnimation {
        var animations = [CABasicAnimation]()
        animations.append(getRotationAnimation())
        animations.append(getScaleAnimation())
        return animations.randomElement()!
    }
    
    static func getRandomImageForAnimation() -> UIImage{
        let namePool = ["gamepad"]
        
        return UIImage(named: namePool.randomElement()!)!
    }
}


