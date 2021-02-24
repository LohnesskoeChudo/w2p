//
//  GameAttributeView.swift
//  w2p
//
//  Created by vas on 21.02.2021.
//

import UIKit

class GameAttributeView: UIControl{
    
    private var label = UILabel(frame: .zero)
    let horizontalPadding: CGFloat = 15
    let verticalPadding: CGFloat = 7
    
    var attrSelected: Bool = false
    var backColor: UIColor!
    
    func setup(text: String, color: UIColor, selectedNow: Bool? = false){
        attrSelected = selectedNow ?? false
        backColor = color
        if attrSelected{
            backgroundColor = UIColor.red.withAlphaComponent(0.5)
        } else {
            backgroundColor = backColor
        }
        label.text = text
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
    
    override func layoutSubviews() {
        let labelSize = self.label.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        self.layer.cornerRadius = (labelSize.height + 2 * verticalPadding) / 2
    }
    
    override var intrinsicContentSize: CGSize{
        return CGSize(width: label.intrinsicContentSize.width + horizontalPadding * 2, height: label.intrinsicContentSize.height + verticalPadding * 2)
    }
    
    func setupActions() {
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(dragExit), for: .touchDragExit)
    }
    
    @objc func touchUp() {
        attrSelected.toggle()
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.allowUserInteraction, .beginFromCurrentState]) {
            if self.attrSelected {
                self.backgroundColor = UIColor.red.withAlphaComponent(0.5)
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
