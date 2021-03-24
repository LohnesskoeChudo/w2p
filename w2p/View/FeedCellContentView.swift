//
//  CellContentView.swift
//  w2p
//
//  Created by vas on 26.02.2021.
//

import UIKit

class CellContentView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("CellContentView", owner: self, options: nil)
        contentView.fixIn(view: self)
    }
}
    
