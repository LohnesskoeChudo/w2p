//
//  GameCardCell.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class GameCardCell: UICollectionViewCell{
        
    var reusing = false
    var id: Int = 0
    
    override func awakeFromNib() {
        setupAppearance()
        contentView.isExclusiveTouch = true
        contentView.fixIn(view: self)
        setupControl()
    }
    
    func setActionToControl(action: @escaping () -> Void ){
        let control = contentView as! CellControlView
        control.action = action
    }
    
    private func setupControl(){
        let control = contentView as! CellControlView
        control.cell = self
        control.viewToAnimate = customContent
    }
    
    @IBOutlet weak var customContent: CellContentView!
    
        
    override func prepareForReuse() {
        super.prepareForReuse()
        customContent.imageView.superview!.isHidden = false
        customContent.imageView.image = nil
    }
    
    private func setupAppearance(){
        self.clipsToBounds = false
        self.contentView.layer.cornerRadius = 16
        if ThemeManager.contentItemsHaveShadows(trait: traitCollection) {
            self.layer.shadowColor = UIColor.darkGray.cgColor
            self.layer.shadowRadius = 2.5
            self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            self.layer.shadowOpacity = 1
        } else {
            self.layer.shadowOpacity = 0
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }

}

enum CardViewComponentsHeight: CGFloat {
    case name = 65
}
