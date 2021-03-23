//
//  ScreenshotCell.swift
//  w2p
//
//  Created by vas on 03.03.2021.
//

import UIKit

class StaticMediaCompactCell: CompactMediaCell {
    
    @IBOutlet weak var mediaView: UIImageView!
    
    override var staticMediaView: UIImageView? {
        get {
            mediaView
        }
        set {
            fatalError("tried to set outlet")
        }
    }
}
