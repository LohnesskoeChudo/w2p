//
//  FilterViewController.swift
//  w2p
//
//  Created by vas on 16.02.2021.
//

import UIKit

class FilterViewController: UIViewController {
    
    var filter: SearchFilter!
    
    @IBOutlet weak var genreFlow: LabelFlowView!
    @IBOutlet weak var themeFlow: LabelFlowView!
    @IBOutlet weak var platformFlow: LabelFlowView!
    
    
    @IBOutlet weak var genreControl: CategoryShowButton!
    @IBOutlet weak var themeControl: CategoryShowButton!
    @IBOutlet weak var platformControl: CategoryShowButton!
    
    @IBAction func genreControlAction(_ sender: CategoryShowButton) {
        show(flowView: genreFlow)
    }
    @IBAction func themeControlAction(_ sender: CategoryShowButton) {
        show(flowView: themeFlow)
    }
    @IBAction func platformControlAction(_ sender: CategoryShowButton) {
        show(flowView: platformFlow)
    }
    
    
    private func show(flowView: UIView){
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            flowView.superview?.isHidden.toggle()
        })
        UIView.animate(withDuration: 0.15, delay: 0.15, animations: {
            flowView.alpha = abs(flowView.alpha - 1)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Filter"
        setupFlows()
        setupControls()
        setupNavigationBar()
    }
    
    private func setupNavigationBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clearFilter))
    }
    
    private func setupControls() {
        genreControl.setup(name: "Genre")
        themeControl.setup(name: "Theme")
        platformControl.setup(name: "Platform")
        
    }

    private func setupFlows(){
        genreFlow.superview?.isHidden = true
        genreFlow.alpha = 0
        themeFlow.superview?.isHidden = true
        themeFlow.alpha = 0
        platformFlow.superview?.isHidden = true
        platformFlow.alpha = 0
        
        for genre in SearchFilter.allGenres.shuffled(){
            let attrView = GameAttributeView()
            attrView.setup(text: genre.name, color: UIColor.purple, selectedNow: filter.genres.contains(genre))
            attrView.setupActions()
            attrView.addTarget(self, action: #selector(genreTapped), for: .touchUpInside)
            attrView.tag = genre.id
            attrView.translatesAutoresizingMaskIntoConstraints = false
            genreFlow.addSubview(attrView)
        }
        for theme in SearchFilter.allThemes.shuffled(){
            let attrView = GameAttributeView()
            attrView.setup(text: theme.name, color: UIColor.green, selectedNow: filter.themes.contains(theme))
            attrView.setupActions()
            attrView.addTarget(self, action: #selector(themeTapped), for: .touchUpInside)
            attrView.tag = theme.id
            attrView.translatesAutoresizingMaskIntoConstraints = false
            themeFlow.addSubview(attrView)
        }
        for platform in SearchFilter.mainPlatforms.shuffled(){
            let attrView = GameAttributeView()
            attrView.setup(text: platform.name, color: UIColor.brown, selectedNow: filter.platforms.contains(platform))
            attrView.setupActions()
            attrView.addTarget(self, action: #selector(platformTapped), for: .touchUpInside)
            attrView.tag = platform.id
            attrView.translatesAutoresizingMaskIntoConstraints = false
            platformFlow.addSubview(attrView)
        }
    }
    
    
    
    @objc func genreTapped(sender: GameAttributeView){
        guard let genre = SearchFilter.allGenres.first(where: {$0.id == sender.tag}) else {return}
        if sender.attrSelected {
            filter.genres.insert(genre)
        } else {
            filter.genres.remove(genre)
        }
    }
    
    @objc func themeTapped(sender: GameAttributeView){
        guard let theme = SearchFilter.allThemes.first(where: {$0.id == sender.tag}) else {return}
        if sender.attrSelected {
            filter.themes.insert(theme)
        } else {
            filter.themes.remove(theme)
        }
    }
    
    @objc func platformTapped(sender: GameAttributeView){
        guard let platform = SearchFilter.mainPlatforms.first(where: {$0.id == sender.tag}) else {return}
        if sender.attrSelected {
            filter.platforms.insert(platform)
        } else {
            filter.platforms.remove(platform)
        }
    }
    
    @objc func clearFilter(){
        filter.resetToDefault()
        let genreAttrs = genreFlow.subviews.compactMap{$0 as? GameAttributeView}
        let themeAttrs = themeFlow.subviews.compactMap{$0 as? GameAttributeView}
        let platformAttrs = platformFlow.subviews.compactMap{$0 as? GameAttributeView}
        print(genreAttrs.count)
        clear(gameAttrs: genreAttrs + themeAttrs + platformAttrs)
    }
    
    private func clear(gameAttrs: [GameAttributeView]){
        for attr in gameAttrs{
            attr.clear()
        }
    }
}
