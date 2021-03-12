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
    let footerWidth: CGFloat = 50
    let footerHeight: CGFloat = 50
    
    
    private func setupFooter(){
        footerImageView.image = UIImage(named: "test")
        control = UIControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        footerImageView = UIImageView()
        footerImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(footerImageView)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: footerWidth),
            heightAnchor.constraint(equalToConstant: footerHeight)
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

}
