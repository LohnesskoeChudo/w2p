//
//  AdditionalPlatformsController.swift
//  w2p
//
//  Created by vas on 15.03.2021.
//

import UIKit

class AdditionalPlatformsController: UIViewController {
    
    var platformViews = [GameAttributeView]()
    var searchFilter: SearchFilter!
    
    @IBOutlet weak var flow: LabelFlowView!
    
    @IBOutlet weak var searchTextFieldBackground: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBAction func editingChanged(_ sender: UITextField) {
        
        updateFlow()
    }
    
    
    private func preparePlatformViews() {
        for platform in SearchFilter.allPlatforms {
            
            guard let platformName = platform.name, let id = platform.id else {continue}
            let platformAttrView = GameAttributeView()
            let color = ThemeManager.colorForPlatformAttribute(trait: traitCollection)
            platformAttrView.setup(text: platformName, color: color, selectedNow: searchFilter.platforms.contains(platform))
            platformAttrView.setupActions()
            platformAttrView.addTarget(self, action: #selector(platformTapped), for: .touchUpInside)
            platformAttrView.tag = id
            platformAttrView.translatesAutoresizingMaskIntoConstraints = false
            
            platformViews.append(platformAttrView)
        }
    }
    
    private func filterPlatforms(search: String) -> [Platform] {
        
        var filteredPlatforms = [Platform]()
        for platform in SearchFilter.allPlatforms {
            if let transformedName = platform.name?.lowercased().replacingOccurrences(of: " ", with: "") {
                
                if transformedName.index(of: search) != nil {
                    filteredPlatforms.append(platform)
                }
            }
        }
        return filteredPlatforms
    }
    
    private func updateFlow() {
        flow.removeAllSubviews()
        
        var platformNamesToShow: Set<String>
        if let searchStr = searchTextField.text?.lowercased().replacingOccurrences(of: " ", with: "") , !searchStr.isEmpty {
            
            platformNamesToShow =  Set(filterPlatforms(search: searchStr).compactMap{$0.name})
        } else {
            platformNamesToShow = Set(SearchFilter.allPlatforms.compactMap{$0.name})
        }
        
        for platformView in platformViews {
            if let platformName = platformView.label.text, platformNamesToShow.contains(platformName) {
                
                flow.addSubview(platformView)
            }
        }
    }
    
    @objc func platformTapped(sender: GameAttributeView) {
        guard let platform = SearchFilter.allPlatforms.first(where: {$0.id == sender.tag}) else {return}
        if sender.attrSelected {
            searchFilter.platforms.insert(platform)
        } else {
            searchFilter.platforms.remove(platform)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparePlatformViews()
        updateFlow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
    }
    
    private func setupSearchBar(){
        searchTextField.delegate = self
        searchTextFieldBackground.layer.cornerRadius = searchTextFieldBackground.frame.height / 2
        searchTextFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
}


extension AdditionalPlatformsController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
