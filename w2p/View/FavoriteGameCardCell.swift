//
//  FavoriteGameCardCell.swift
//  w2p
//
//  Created by vas on 28.02.2021.
//

import UIKit

class FavoriteGameCardCell: UITableViewCell{
        
    var id: Int = 0
    static let imageWidth:CGFloat = 80
    static let imageHeight:CGFloat = 110
    
    @IBOutlet weak var ratingView: CircularRatingView!
    
    var isLoading = false

    override func awakeFromNib() {
        setupAppearance()
        setupControl()
    }
    

    @IBOutlet weak var label: UILabel!

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var control: CellControlView!
    @IBOutlet weak var gameImageView: UIImageView!
    @IBOutlet weak var imageViewContainer: UIView!
    
    private func setupAppearance(){
        self.clipsToBounds = false
        control.layer.cornerRadius = 16
        if ThemeManager.contentItemsHaveShadows(trait: traitCollection) {
            control.layer.shadowColor = UIColor.darkGray.cgColor
            control.layer.shadowRadius = 2.5
            control.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
            
            control.layer.shadowOpacity = 1
        } else {
            control.layer.shadowOpacity = 0
        }
        gameImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        imageViewContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        gameImageView.layer.cornerRadius = 16
        imageViewContainer.layer.cornerRadius = 16
        
        imageWidthConstraint.constant = Self.imageWidth
        imageHeightConstraint.constant = Self.imageHeight
    }
    
    
    func startContentLoadingAnimation(){
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        
        animation.fromValue = ThemeManager.secondColorForImagePlaceholder(trait: traitCollection).cgColor
        animation.toValue = ThemeManager.firstColorForImagePlaceholder(trait: traitCollection).cgColor
        animation.duration = 1
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.repeatCount = .infinity
        imageViewContainer.layer.add(animation, forKey: "image loading animation")
    }
    
    func endContentLoadingAnimation(){
        imageViewContainer.layer.removeAllAnimations()
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    
    func setupRatingView(with rating: Double?) {
        if let rating = rating, rating > 0{
            ratingView.rating = rating
        } else {
            ratingView.isHidden = true
        }
    }
    
    func setActionToControl(action: @escaping () -> Void) {
        control.action = action
    }
    
    private func setupControl(){
        control.container = control
        control.viewToAnimate = control
    }
    

    override func prepareForReuse() {
        gameImageView.image = nil
        label.text = nil
        gameImageView.alpha = 0
        isLoading = false
        id = 0
        ratingView.isHidden = false
    }
}
