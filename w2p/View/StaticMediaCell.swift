//
//  StaticMediaCell.swift
//  w2p
//
//  Created by vas on 27.03.2021.
//

import UIKit

class StaticMediaCell: GameMediaCell {
    var reloadAction: (() -> Void)?
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    override var staticMediaView: UIImageView? {
        mediaImageView
    }
    
    override func reload() {
        reloadAction?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mediaImageView.image = nil
        reloadAction = nil
    }
}
