//
//  GameAttributeView.swift
//  w2p
//
//  Created by vas on 21.02.2021.
//

import UIKit

class GameAttributeView: UIControl {
    
    var attrSelected: Bool = false
    private var label = UILabel(frame: .zero)
    private let horizontalPadding: CGFloat = 15
    private let verticalPadding: CGFloat = 7
    private var backColor: UIColor!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
    }
    
    
    func setup(text: String, color: UIColor, selectedNow: Bool? = false){
        attrSelected = selectedNow ?? false
        backColor = color
        if attrSelected{
            backgroundColor = ThemeManager.colorForSelection(trait: traitCollection)
        } else {
            backgroundColor = backColor
        }
        label.text = text
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w = frame.width
        let h = frame.height
        label.frame = CGRect(x: horizontalPadding, y: verticalPadding, width: w - 2*(horizontalPadding), height: h - 2*(verticalPadding))
        
        let labelSize = label.intrinsicContentSize
        self.layer.cornerRadius = (labelSize.height + 2 * verticalPadding) / 2
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width + horizontalPadding * 2, height: label.intrinsicContentSize.height + verticalPadding * 2)
    }
    
    func setupActions() {
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(dragExit), for: .touchDragExit)
        self.addTarget(self, action: #selector(dragExit), for: .touchCancel)
    }
    
    @objc func touchUp() {
        attrSelected.toggle()
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.allowUserInteraction, .beginFromCurrentState]) {
            if self.attrSelected {
                self.backgroundColor = ThemeManager.colorForSelection(trait: self.traitCollection)
            } else {
                self.backgroundColor = self.backColor
            }
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc func touchDown() {
        UIView.animate(withDuration: 0.1, delay: 0,options: [.allowUserInteraction, .beginFromCurrentState]){
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc func dragExit() {
        UIView.animate(withDuration: 0.1){
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func clear(animated: Bool){
        attrSelected = false
        let action = {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = self.backColor
        }
        if animated {
            UIView.animate(withDuration: 0.2) { action() }
        } else {
            action()
        }
    }
}
