//  CommonButton.swift
//  w2p
//  Created by vas on 24.02.2021.

import UIKit

class TransferButton: UIControl{
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("TransferButton", owner: self, options: nil)
        contentView.fixIn(view: self)
        setupActions()
    }
    
    func setup(name: String){
        textLabel.text = name
    }
    
    func setupActions(){
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchCancel)
    }
    
    @objc func touchUp(){
        FeedbackManager.generateFeedbackForButtonsTapped()
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.allowUserInteraction]) {
            self.textLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc func touchDown(){
        UIView.animate(withDuration: 0.1 , delay: 0, options: [.allowUserInteraction]){
            self.textLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    @objc func touchDragExit(){
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.allowUserInteraction]) {
            self.textLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    
}
