//
//  HeaderWaterfallLayoutView.swift
//  w2p
//
//  Created by vas on 26.03.2021.
//

import UIKit

class HeaderWaterfallLayoutView: UICollectionReusableView {
    
    override var reuseIdentifier: String? {
        "header"
    }
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        addSubview(label)
        label.fixIn(view: self, up: 20, down: 10, leading: 20, trailing: 20)
    }
}



