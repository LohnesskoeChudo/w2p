//
//  GameBrowserFooter.swift
//  w2p
//
//  Created by vas on 12.03.2021.
//

import UIKit

class GameBrowserFooter: UICollectionReusableView {
    
    
    var control: UIControl!
    var footerImageView: UIImageView!
    static let footerWidth: CGFloat = 50
    static let footerHeight: CGFloat = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        translatesAutoresizingMaskIntoConstraints = false
        control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        footerImageView = UIImageView()
        footerImageView.image = UIImage(named: "test")
        footerImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Self.footerWidth),
            heightAnchor.constraint(equalToConstant: Self.footerHeight)
        ])
        footerImageView.fixIn(view: control)
        control.fixIn(view: self)
        setupFooterActions()
    }
    

    
    private func setupFooterActions() {
        control.addTarget(self, action: #selector(self.footerTouchUpInside), for: .touchUpInside)
        control.addTarget(self, action: #selector(self.footerTouchDownInside), for: .touchDown)
        control.addTarget(self, action: #selector(footerTouchDragExit), for: .touchDragExit)
        control.addTarget(self, action: #selector(footerTouchDragExit), for: .touchCancel)
    }
    
    @objc func footerTouchDownInside() {
        
    }
    
    @objc func footerTouchUpInside() {
        
    }
    
    @objc func footerTouchDragExit() {
        
    }
    
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        layoutAttributes.frame.size = systemLayoutSizeFitting(UICollectionView.layoutFittingCompressedSize)
        
        return layoutAttributes
        
    }

}
