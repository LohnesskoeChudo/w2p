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
    }
    
    @objc func touchUp(){
        
    }
    
    @objc func touchDown(){
        
    }
    
    @objc func touchDragExit(){
        
    }
    
}
    
