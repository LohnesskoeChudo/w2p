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
    
    @IBOutlet weak var genreControl: FilterCategoryButton!
    @IBOutlet weak var themeControl: FilterCategoryButton!
    @IBOutlet weak var platformControl: FilterCategoryButton!
    
    @IBAction func genreControlAction(_ sender: FilterCategoryButton) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupControls()

    }
    
    private func setupControls() {
        genreControl.setup(name: "Genre")
        themeControl.nameLabel.text = "Theme"
        platformControl.nameLabel.text = "Platform"
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
