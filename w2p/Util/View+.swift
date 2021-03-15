//
//  View+.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import UIKit

extension UIView{
    
    func fixIn(view: UIView){
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func removeAllSubviews() {
        subviews.forEach{$0.removeFromSuperview()}
    }
}
