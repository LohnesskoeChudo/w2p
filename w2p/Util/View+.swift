//
//  View+.swift
//  w2p
//
//  Created by vas on 23.02.2021.
//

import UIKit

extension UIView{
    
    func fixIn(view: UIView, up: CGFloat? = nil, down: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil){
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: up ?? 0),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading ?? 0),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(trailing ?? 0)),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(down ?? 0))
        ])
    }
    
    func removeAllSubviews() {
        subviews.forEach{$0.removeFromSuperview()}
    }
}





extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
