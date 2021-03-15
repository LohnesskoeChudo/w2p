//
//  GameAttributeView.swift
//  w2p
//
//  Created by vas on 21.02.2021.
//

import UIKit

class GameAttributeView: UIControl{
    
    var label = UILabel(frame: .zero)
    let horizontalPadding: CGFloat = 15
    let verticalPadding: CGFloat = 7
    
    var attrSelected: Bool = false
    var backColor: UIColor!
    
    
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
        label.lineBreakMode = .byClipping
        label.lineBreakStrategy = .standard
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
        ])
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
        let labelSize = self.label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.layer.cornerRadius = (labelSize.height + 2 * verticalPadding) / 2
    }
    
    override var intrinsicContentSize: CGSize{
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
    
    private func animateClear(){
        UIView.animate(withDuration: 0.2){
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.backgroundColor = self.backColor
        }
    }
    
    func clear(){
        attrSelected = false
        animateClear()
    }
}
