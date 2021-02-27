//
//  GameCardCell.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class GameCardCell: UICollectionViewCell{
        
    
    var reusing: Bool = false
    var action: (() -> Void)?
    var id: Int = 0
    
    override func awakeFromNib() {
        setupAppearance()
        setupActionsForEvents()
        contentView.isExclusiveTouch = true
        contentView.fixIn(view: self)

    }
    

    @IBOutlet weak var customContent: CellContentView!
    
        
    override func prepareForReuse() {
        customContent.imageView.superview!.isHidden = false
        customContent.imageView.image = nil
    }
    
    private func setupAppearance(){
        self.clipsToBounds = false
        self.contentView.layer.cornerRadius = 16
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 2.5
        self.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        self.layer.shadowOpacity = 1
    }
    
    private func setupActionsForEvents(){
        for subview in contentView.subviews{
            subview.isUserInteractionEnabled = false
        }
        let cv = contentView as! UIControl
        cv.addTarget(self, action: #selector(touchDown), for: .touchDown)
        cv.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        cv.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
    }
    

    var touchDownAnimationFinished = true
    
    @objc func touchDown(){
        touchDownAnimationFinished = false
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .curveEaseIn,.beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.95 , y: 0.95)
        }, completion: {
            _ in
            self.touchDownAnimationFinished = true
        })
    }
    
    @objc func touchUp(){
        UIView.animate(withDuration: 0.1, delay: touchDownAnimationFinished ? 0 : 0.1, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1 , y: 1)
        }){ _ in
            self.action?()
        }
    }
    
    @objc func touchDragExit(){
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState]){
            self.contentView.transform = CGAffineTransform(scaleX: 1 , y: 1)
        }
    }
}

enum CardViewComponentsHeight: CGFloat {
    case name = 65
}
