//
//  FavoriteGameCardCell.swift
//  w2p
//
//  Created by vas on 28.02.2021.
//

import UIKit

class FavoriteGameCardCell: UITableViewCell{
        
    var id: Int = 0
    static let imageWidth:CGFloat = 50
    static let imageHeight:CGFloat = 75
    
    override func awakeFromNib() {
        setupAppearance()
    }
    
    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var gameImageView: UIImageView!
    
    private func setupAppearance(){
        self.clipsToBounds = false
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.darkGray.cgColor
        container.layer.shadowRadius = 2.5
        container.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        container.layer.shadowOpacity = 1
        gameImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        gameImageView.layer.cornerRadius = 16
        
        imageWidthConstraint.constant = Self.imageWidth
        imageHeightConstraint.constant = Self.imageHeight
    }
    

    override func prepareForReuse() {
        gameImageView.image = nil
        label.text = nil
        id = 0
    }
}
