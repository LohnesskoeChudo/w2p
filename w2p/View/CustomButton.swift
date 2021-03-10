//
//  CustomButton.swift
//  w2p
//
//  Created by vas on 01.03.2021.
//

import UIKit

class CustomButton: UIControl{
    
    override init(frame: CGRect){
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        customInit()
    }
    
    func customInit(){
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setActions()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = bounds.size.height / 2
    }
    
    func setActions(){
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchCancel)
    }
    
    var touchDownAnimationFinished = true

    
    
    @objc func touchDown(){
        touchDownAnimationFinished = false
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn,.beginFromCurrentState], animations: {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }, completion: {
            _ in
            self.touchDownAnimationFinished = true
        })
    }
    
    @objc func touchUp(){
        
        UIView.animate(withDuration: 0.15, delay: touchDownAnimationFinished ? 0 : 0.15, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
            FeedbackManager.generateFeedbackForButtonsTapped()
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        })
    }
    
    @objc func touchDragExit(){
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState]){
            self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
}
    
