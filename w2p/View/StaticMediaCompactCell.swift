//
//  ScreenshotCell.swift
//  w2p
//
//  Created by vas on 03.03.2021.
//

import UIKit

class StaticMediaCompactCell: GameMediaCell {
    
    
    @IBOutlet weak var mediaView: UIImageView! {
        didSet {
            tapRecognizer.addTarget(self, action: #selector(contentTapped))
            mediaView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    var tapAction: (() -> Void)?
    @objc func contentTapped() {
        tapAction?()
    }
    
    let tapRecognizer = UITapGestureRecognizer()
    
    override var staticMediaView: UIImageView? {
        mediaView
    }
}
