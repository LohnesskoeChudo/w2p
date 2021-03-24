//
//  AdditionalPlatformsController.swift
//  w2p
//
//  Created by vas on 15.03.2021.
//

import UIKit

class AdditionalPlatformsController: UIViewController {
    
    var platformViews = [String: GameAttributeView]()
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
            
            platformViews[platformName] = platformAttrView
        }
    }
    
    private func filterPlatforms(search: String) -> BinaryHeap<Platform, String.Index> {
        
        let filteredPlatforms = BinaryHeap<Platform, String.Index>(type: .min)
        for platform in SearchFilter.allPlatforms {
            if let transformedName = platform.name?.lowercased().replacingOccurrences(of: " ", with: "") {
                if let index = transformedName.index(of: search) {
                    filteredPlatforms.insert(node: .init(data: platform, priority: index))
                }
            }
        }
        
        return filteredPlatforms
    }
    
    private func updateFlow() {
        flow.removeAllSubviews()
        if let searchStr = searchTextField.text?.lowercased().replacingOccurrences(of: " ", with: "") , !searchStr.isEmpty {
            let filteredPlatforms = filterPlatforms(search: searchStr)
            while let platform = filteredPlatforms.popTop() {
                if let name = platform.data.name, let platformView = platformViews[name]{
                    flow.addSubview(platformView)
                }
            }
        } else {
            for platformView in platformViews.values {
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
        setupNavigationItem()
        preparePlatformViews()
        updateFlow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "All Platforms"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(clearPlatforms))
    }
    
    @objc private func clearPlatforms() {
        searchTextField.text = nil
        searchFilter.platforms = []
        UIView.animate(withDuration: flow.subviews.isEmpty ? 0 : 0.3) {
            self.flow.alpha = 0
        } completion: { _ in
            self.searchFilter.platforms = []
            self.updateFlow()
            self.clearPlatformViews(animated: false)
            UIView.animate(withDuration: 0.3, animations: {
                self.flow.alpha = 1
            })
        }
    }
    
    private func clearPlatformViews(animated: Bool) {
        for platformView in platformViews.values {
            platformView.clear(animated: animated)
        }
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
