//
//  FilterViewController.swift
//  w2p
//
//  Created by vas on 16.02.2021.
//

import UIKit

class FilterViewController: UIViewController {
    
    var filter: SearchFilter!
    
    @IBOutlet weak var flow: LabelFlowView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

    }
    
    func setup(){
        navigationItem.title = "Filter"
        
        var arr = ["asdfafd ","adfk ","asdkfjlas ","askf ","adfjkdfadf ","aksdf ","asda ","asdfsdf ", "lsdkjflasdjkfljsdlfkfdkjasdfjskddskfj"]
        
        for k in arr{
            let label = GameAttributeView()
            label.setup(text: k, color: UIColor.purple)
            label.translatesAutoresizingMaskIntoConstraints = false
            flow.addSubview(label)
        }
    }
    
    
}
