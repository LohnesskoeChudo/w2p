//
//  ScreenshotCell.swift
//  w2p
//
//  Created by vas on 03.03.2021.
//

import UIKit

class StaticMediaCompactCell: GameMediaCell {
    
    var tapAction: (() -> Void)?
    private let tapRecognizer = UITapGestureRecognizer()
    
    @IBOutlet weak var mediaView: UIImageView! {
        didSet {
            tapRecognizer.addTarget(self, action: #selector(contentTapped))
            mediaView.addGestureRecognizer(tapRecognizer)
        }
    }

    @objc func contentTapped() {
        tapAction?()
    }
    
    override var staticMediaView: UIImageView? {
        mediaView
    }
}
