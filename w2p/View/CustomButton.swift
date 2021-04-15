//
//  CustomButton.swift
//  w2p
//
//  Created by vas on 01.03.2021.
//

import UIKit

class CustomButton: UIControl {
    
    private var colorForPressedState: UIColor = UIColor.black.withAlphaComponent(0.3)
    private var colorForReleasedState: UIColor = UIColor.black.withAlphaComponent(0.6)
    private var touchDownAnimationFinished = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = bounds.size.height / 2
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setup(colorPressed: UIColor, colorReleazed: UIColor) {
        self.colorForPressedState = colorPressed
        self.colorForReleasedState = colorReleazed
        self.backgroundColor = colorReleazed
    }
    
    private func commonInit() {
        setActions()
        self.backgroundColor = colorForReleasedState
    }

    private func setActions() {
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchCancel)
    }
    
    @objc func touchDown() {
        touchDownAnimationFinished = false
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseIn,.beginFromCurrentState], animations: {
            self.backgroundColor = self.colorForPressedState
        }, completion: {
            _ in
            self.touchDownAnimationFinished = true
        })
    }
    
    @objc func touchUp() {
        UIView.animate(withDuration: 0.15, delay: touchDownAnimationFinished ? 0 : 0.15, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
            FeedbackManager.generateFeedbackForButtonsTapped()
            self.backgroundColor = self.colorForReleasedState
        })
    }
    
    @objc func touchDragExit() {
        UIView.animate(withDuration: 0.15, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState]) {
            self.backgroundColor = self.colorForReleasedState
        }
    }
}
    
