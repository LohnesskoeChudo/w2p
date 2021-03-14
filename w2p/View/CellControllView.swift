//
//  CellControllView.swift
//  w2p
//
//  Created by vas on 10.03.2021.
//

import UIKit

class CellControlView: UIControl {
    
    var action: (() -> Void)?
    weak var container: UIView?
    weak var viewToAnimate: UIView?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        setupActionsForEvents()
    }
    
    private func setupActionsForEvents(){
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
        addTarget(self, action: #selector(touchDragExit), for: .touchCancel)
    }
    
    var touchDownAnimationFinished = true

    @objc func touchDown(){
        touchDownAnimationFinished = false
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn,.beginFromCurrentState], animations: {
            self.viewToAnimate?.alpha = 0.6
            if ThemeManager.contentItemsHaveShadows(trait: self.traitCollection) {
                self.container?.layer.shadowOpacity = 0.5
            }
        }, completion: {
            _ in
            self.touchDownAnimationFinished = true
        })
    }
    
    @objc func touchUp(){
        FeedbackManager.generateFeedbackForButtonsTapped()
        self.action?()
        UIView.animate(withDuration: 0.15, delay: touchDownAnimationFinished ? 0 : 0.15, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
            self.viewToAnimate?.alpha = 1
            if ThemeManager.contentItemsHaveShadows(trait: self.traitCollection){
                self.container?.layer.shadowOpacity = 1
            }
        })
    }
    
    @objc func touchDragExit(){
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState]){
            self.viewToAnimate?.alpha = 1
            if ThemeManager.contentItemsHaveShadows(trait: self.traitCollection){
                self.container?.layer.shadowOpacity = 1
            }}
    }
    
    
}
