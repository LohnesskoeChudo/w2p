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
    
    
    override func awakeFromNib() {
        appearanceSetup()
        setupActionsForEvents()
        contentView.isExclusiveTouch = true
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var genreLabel: UILabel!
    var id: String = ""
    
    func appearanceSetup(){
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
    
    func setupActionsForEvents(){
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
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn,.beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 0.95 , y: 0.95)
            self.contentView.alpha = 0.7
        }, completion: {
            _ in
            self.touchDownAnimationFinished = true
        })
    }
    
    @objc func touchUp(){
        UIView.animate(withDuration: 0.15, delay: touchDownAnimationFinished ? 0 : 0.15, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1 , y: 1)
            self.contentView.alpha = 1
        }, completion: {
            _ in
        })
    }
    
    @objc func touchDragExit(){
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
            self.contentView.transform = CGAffineTransform(scaleX: 1 , y: 1)
            self.contentView.alpha = 1
        }, completion: {
            _ in
        })
    }
}

enum CardViewComponentsHeight: CGFloat {
    case genre = 40
    case rating = 25
    case name = 65
}
