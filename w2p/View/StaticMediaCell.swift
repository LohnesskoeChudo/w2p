//
//  ScreenshotCell.swift
//  w2p
//
//  Created by vas on 03.03.2021.
//

import UIKit

class StaticMediaCell: UICollectionViewCell {
    
    var id: Int?
    
    @IBOutlet weak var staticMediaView: UIImageView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        id = nil
        staticMediaView.image = nil
    }

}
