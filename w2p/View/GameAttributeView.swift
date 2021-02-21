//
//  GameAttributeView.swift
//  w2p
//
//  Created by vas on 21.02.2021.
//

import UIKit

class GameAttributeView: UIView{
    
    private var label = UILabel(frame: .zero)
    let horizontalPadding: CGFloat = 15
    let verticalPadding: CGFloat = 7
    
    func setup(text: String, color: UIColor){
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        backgroundColor = color
    }
    
    override func layoutSubviews() {
        let labelSize = self.label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        self.layer.cornerRadius = (labelSize.height + 2 * verticalPadding) / 2
    }
    
    override var intrinsicContentSize: CGSize{
        let labelSize = label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        return CGSize(width: labelSize.width + horizontalPadding * 2, height: labelSize.height + verticalPadding * 2)
    }
    
}
