//
//  GameCardCell.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class GameCardCell: UICollectionViewCell{
    
    override func awakeFromNib() {
        setup()
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    var id: String = ""
    
    func setup(){
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        self.contentView.layer.borderWidth = 2.5
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.cornerRadius = 15
    }
    
    override func prepareForReuse() {
        coverImageView.superview!.isHidden = false
        genreLabel.superview!.isHidden = false
        coverImageView.image = nil
        genreLabel.text = ""
    }
}

enum CardViewComponentsHeight: CGFloat {
    case genre = 40
    case rating = 25
    case name = 65
}
