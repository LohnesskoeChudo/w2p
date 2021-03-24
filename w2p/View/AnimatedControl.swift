//
//  AnimatedControl.swift
//  w2p
//
//  Created by vas on 09.03.2021.
//

import UIKit

class AnimatedControl: UIControl {
    
    var tapRecognizer: UITapGestureRecognizer!
    
    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        setupActions()
    }
    
    private func setupActions(){
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer){
        switch sender.state {
        case .began:
            print("Began")
        case .changed:
            print("Changed")
        case .ended:
            print("Ended")
        default:
            return
        }
    }
    
    func touchUpInside(){
        
    }
    
    func touchDown(){
        
    }
    
    func touchDragExit(){
        
    }
}
