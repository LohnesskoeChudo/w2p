//
//  FilterCategoryButton.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import UIKit

class CategoryShowButton: UIControl {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var opened: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func awakeFromNib() {
        setupActions()
    }
    
    func commonInit(){
        Bundle.main.loadNibNamed("CategoryShowButton", owner: self, options: nil)
        contentView.fixIn(view: self)
    }
    
    func setup(name: String){
        nameLabel.text = name
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    
    func setupActions(){
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
    }
    
    @objc func touchUp(){
        self.opened.toggle()
        UIView.animate(withDuration: 0.1, delay: 0.1) {
            self.nameLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            if self.opened{
                self.imageView.transform = CGAffineTransform.identity
            } else {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            }
        }
    }
    
    @objc func touchDown(){
        UIView.animate(withDuration: 0.1 , delay: 0) {
            self.nameLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.imageView.transform = self.imageView.transform.scaledBy(x: 0.9, y: 0.9)
        }
    }
    
    @objc func touchDragExit(){
        
    }
}
