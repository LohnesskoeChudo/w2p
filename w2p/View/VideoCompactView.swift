//
//  PlayerView.swift
//  w2p
//
//  Created by vas on 21.03.2021.
//

import UIKit
import AVFoundation


class VideoCompactView: UIView {
    
    var player: AVPlayer? {
        get {
            playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    
}
