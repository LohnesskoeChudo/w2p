//
//  FilterViewController.swift
//  w2p
//
//  Created by vas on 16.02.2021.
//

import UIKit

class FilterViewController: UIViewController {
    
    var filter: SearchFilter!
    @IBOutlet var sectionBackgroundViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupSectionBackViews()
        
    }
    
    func setup(){
        navigationItem.title = "Filter"
    }
    
    func setupSectionBackViews(){
        for backView in sectionBackgroundViews{
            backView.layer.cornerRadius = 20
        }
    }
}
