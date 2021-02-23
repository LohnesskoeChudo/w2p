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
}
