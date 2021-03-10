//
//  CircularRatingView.swift
//  w2p
//
//  Created by vas on 10.03.2021.
//

import UIKit

class CircularRatingView: UIView{
    
    var ratingLabel = UILabel()
    var rating: Double = 0 {
        didSet {
            ratingLabel.text = "\(Int(rating))"
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    

    private func commonInit(){
        ratingLabel.text = "\(Int(rating))"
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.textColor = .secondaryLabel
        addSubview(ratingLabel)
        NSLayoutConstraint.activate([
            ratingLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ratingLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    
    override func draw(_ rect: CGRect) {
        let backPath = UIBezierPath()
        let lineWidth: CGFloat = 8
        let radius = (bounds.width / 2) - (lineWidth / 2)
        backPath.lineWidth = lineWidth
        
        let backColor = ThemeManager.colorForUIelementsBackground(trait: traitCollection)
        backColor.setStroke()
        backPath.addArc(withCenter: bounds.center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        backPath.stroke()
        
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineWidth = lineWidth * 0.5
        let ratingColor = RedGreenMaper(minValue: 0, maxValue: 100).mapToColor(value: rating)
        ratingColor?.setStroke()
        path.addArc(withCenter: bounds.center, radius: radius, startAngle: -CGFloat.pi/2, endAngle: -(CGFloat.pi * CGFloat(rating) / 50) - CGFloat.pi/2, clockwise: false)
        path.stroke()
    }
    
    
    
}
