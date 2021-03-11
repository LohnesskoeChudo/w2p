//
//  LineRagingVIew.swift
//  w2p
//
//  Created by vas on 11.03.2021.
//

import UIKit

class LineRatingView: UIView {
    
    let ratingLabel = UILabel()
    let ratingLabelContainer = UIView()
    let backRatingView = UIView()
    let ratingViewPadding: CGFloat = 5
    let spacing: CGFloat = 10
    let ratingView = UIView()
    var rating: Double = 0 {
        didSet{
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        updateAppearance()
        ratingLabelContainer.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        backRatingView.translatesAutoresizingMaskIntoConstraints = false
        
        ratingLabelContainer.addSubview(ratingLabel)
        addSubview(ratingLabelContainer)
        addSubview(backRatingView)
        backRatingView.addSubview(ratingView)
        
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: ratingLabelContainer.topAnchor, constant: 10),
            ratingLabel.bottomAnchor.constraint(equalTo: ratingLabelContainer.bottomAnchor, constant: -10),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingLabelContainer.leadingAnchor, constant: 10),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingLabelContainer.trailingAnchor, constant: -10),
            
            ratingLabelContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            ratingLabelContainer.topAnchor.constraint(equalTo: topAnchor),
            ratingLabelContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let extCornerRadius = frame.height * 0.8 / 2
        ratingLabelContainer.layer.cornerRadius = extCornerRadius
        backRatingView.layer.cornerRadius = extCornerRadius
        let insCornerRadius = extCornerRadius - ratingViewPadding
        ratingView.layer.cornerRadius = insCornerRadius
        
        ratingView.backgroundColor = RedGreenMaper(minValue: 0, maxValue: 100).mapToColor(value: rating)
        
        ratingLabel.text = "\(Int(rating))"
        
        
        let labelContainerWidth = ratingLabelContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
        let ratingBackWidth = frame.width - (labelContainerWidth + spacing)
        
        
        let backYOffset = (frame.height - frame.height * 0.8) / 2
        backRatingView.frame = CGRect(x: labelContainerWidth + spacing, y: backYOffset, width: ratingBackWidth, height: frame.height * 0.8)

        let ratingWidth: CGFloat = (CGFloat(rating) / 100) * (backRatingView.frame.width - 2 * ratingViewPadding)
        let ratingHeight: CGFloat = backRatingView.frame.height - 2 * ratingViewPadding
        
        ratingView.frame = CGRect(x: ratingViewPadding, y: ratingViewPadding, width: ratingWidth, height: ratingHeight )
        

    }
    
    private func updateAppearance(){
        ratingLabelContainer.backgroundColor = ThemeManager.colorForUIelementsBackground(trait: traitCollection)
        backRatingView.backgroundColor = ThemeManager.colorForUIelementsBackground(trait: traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateAppearance()
    }
}
