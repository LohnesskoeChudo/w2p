//
//  FilterCategoryButton.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import UIKit

class FilterCategoryButton: UIControl {
    
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
    
    func commonInit(){
        Bundle.main.loadNibNamed("FilterCategoryButton", owner: self, options: nil)
        contentView.fixIn(view: self)
    }
    
    func setup(name: String){
        nameLabel.text = name
        setupActions()
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
    }
    
    func setupActions(){
        self.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: .touchDown)
        self.addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
    }
    
    @objc func touchUp(){
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [.allowUserInteraction], animations: {
            self.nameLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            if self.opened{
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
            } else {
                self.imageView.transform = CGAffineTransform.identity
            }
            self.opened.toggle()
            print(self.opened)
        }, completion: {
            _ in
        })

    }
    
    @objc func touchDown(){
        print("down")
        UIView.animate(withDuration: 0.1 , delay: 0, options: [.allowUserInteraction], animations: {
            
            self.nameLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.imageView.transform = self.imageView.transform.scaledBy(x: 0.9, y: 0.9)
            
        }, completion: {
            _ in
        })
    }
    
    @objc func touchDragExit(){
        
    }
    
    
    
}
