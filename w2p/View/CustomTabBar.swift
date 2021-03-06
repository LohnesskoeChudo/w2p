//
//  CustomTabBar.swift
//  w2p
//
//  Created by vas on 05.03.2021.
//

import UIKit

class CustomTabBar: UIView {
    
    var tabItemsContainer: UIStackView
    var selectedControllerIndex: Int?
    
    init(){
        tabItemsContainer = UIStackView()
        tabItemsContainer.spacing = 20
        tabItemsContainer.axis = .horizontal
        tabItemsContainer.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: .zero)
        addSubview(tabItemsContainer)
        NSLayoutConstraint.activate([
            tabItemsContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            tabItemsContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            tabItemsContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            tabItemsContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8),
            
            self.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(tabBarItem: CustomTabBarItem) {
        tabBarItem.translatesAutoresizingMaskIntoConstraints = false
        tabItemsContainer.addArrangedSubview(tabBarItem)
    }
   
}


class CustomTabBarItem: UIView {
    
    let iconView = UIImageView()
    let label = UILabel()
    
    init(activeImage: UIImage, inactiveImage: UIImage, text: String) {
        super.init(frame: .zero)
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false

        iconView.image = inactiveImage
        iconView.backgroundColor = .black
        label.text = text
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
            
            iconView.widthAnchor.constraint(equalToConstant: 25),
            iconView.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
