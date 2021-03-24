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
    @IBOutlet weak var morePlatformsButton: UIButton!
    @IBOutlet weak var platformControl: CategoryShowButton!
    
    
    
    @IBAction func morePlatformsTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
    }
    
    
    @IBAction func genreControlAction(_ sender: CategoryShowButton) {
        if sender.opened{
            show(section: genreFlow.superview, subview: genreFlow, animated: true)
        } else {
            hide(section: genreFlow.superview, subview: genreFlow, animated: true)
        }
    }
    @IBAction func themeControlAction(_ sender: CategoryShowButton) {
        if sender.opened{
            show(section: themeFlow.superview, subview: themeFlow, animated: true)
        } else {
            hide(section: themeFlow.superview, subview: themeFlow, animated: true)
        }
    }
    @IBAction func platformControlAction(_ sender: CategoryShowButton) {
        if sender.opened{
            show(section: platformFlow.superview, subview: platformFlow, animated: true)
        } else {
            hide(section: platformFlow.superview, subview: platformFlow, animated: true)
        }
    }
    
    @IBOutlet weak var ratingSwitch: UISwitch!
    @IBAction func switchRatingAction(_ sender: UISwitch) {
        if sender.isOn {
            filter.ratingLowerBound = 1
            filter.ratingUpperBound = 100
        } else {
            filter.ratingLowerBound = nil
            filter.ratingUpperBound = nil
        }
        updateRatingUI(animated: true)
    }
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingSliderContainer: UIView!
    var ratingSlider: DoubleSlider!
   
    

    @IBOutlet weak var singleplayerSwitch: UISwitch!
    @IBOutlet weak var multiplayerSwitch: UISwitch!
    @IBAction func singleplayerSwitch(_ sender: UISwitch) {
        filter.singleplayer = sender.isOn
    }
    @IBAction func multiplayerSwitch(_ sender: UISwitch) {
        filter.multiplayer = sender.isOn
    }
    
    
    @IBOutlet weak var lowerDateBoundSwitch: UISwitch!
    @IBOutlet weak var upperDateBoundSwitch: UISwitch!
    @IBAction func lowerBoundSwitch(_ sender: UISwitch) {
        if sender.isOn{
            filter.releaseDateLowerBound = Date(timeIntervalSince1970: 0)
        } else {
            filter.releaseDateLowerBound = nil
        }
        updateReleaseDateUI(animated: true)
    }
    @IBAction func upperBoundSwitch(_ sender: UISwitch) {
        if sender.isOn{
            filter.releaseDateUpperBound = Date(timeIntervalSince1970: 2147400000)
        } else {
            filter.releaseDateUpperBound = nil
        }
        updateReleaseDateUI(animated: true)
    }
    
    @IBOutlet weak var dateLowerBound: UIDatePicker!
    @IBOutlet weak var dateUpperBound: UIDatePicker!
    @IBAction func lowerDateChange(_ sender: UIDatePicker) {
        filter.releaseDateLowerBound = sender.date
        dateUpperBound.minimumDate = sender.date
    }
    
    @IBAction func upperDateChange(_ sender: UIDatePicker) {
        filter.releaseDateUpperBound = sender.date
        dateLowerBound.maximumDate = sender.date
    }

    @IBOutlet weak var noEmptyGamesSwitch: UISwitch!
    @IBOutlet weak var noExtensionsSwitch: UISwitch!
    @IBAction func noEmptyGamesSwitched(_ sender: UISwitch) {
        filter.excludeEmptyGames = sender.isOn
    }
    @IBAction func noExtensionsSwitched(_ sender: UISwitch) {
        filter.excludeExtensions = sender.isOn
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "morePlatforms":
            let destinationVC = segue.destination as! AdditionalPlatformsController
            destinationVC.searchFilter = filter
        default:
            return
        }
    }
    
    private func show(section: UIView?, subview: UIView, animated: Bool){
        let showSection = {section?.isHidden = false}
        let showSubview = {subview.alpha = 1}
        
        if animated{
            UIView.animate(withDuration: 0.3) { showSection() }
            UIView.animate(withDuration: 0.15, delay: 0.15) { showSubview() }
        } else {
            showSection()
            showSubview()
        }
    }
    
    private func hide(section: UIView?, subview: UIView, animated: Bool){
        let hideSection = { section?.isHidden = true }
        let hideSubview = { subview.alpha = 0 }
        
        if animated{
            UIView.animate(withDuration: 0.3){hideSection()}
            UIView.animate(withDuration: 0.15, delay: 0.15) { hideSubview()}
        } else {
            hideSection()
            hideSubview()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Filter"
        navigationController?.navigationBar.tintColor = ThemeManager.colorForBarButtons(trait: traitCollection)
        setupFlows()
        setupControls()
        setupNavigationBar()
        setupRating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFlows()
        updateGameModesUI()
        updateReleaseDateUI(animated: false)
        updateExcludeUI(animated: false)
    }
    
    private func updateControls() {
        morePlatformsButton.layer.cornerRadius = (morePlatformsButton.frame.height / 2)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateControls()
    }
    
    private func updateGameModesUI(){
        singleplayerSwitch.setOn(filter.singleplayer, animated: true)
        multiplayerSwitch.setOn(filter.multiplayer, animated: true)
    }
    
    private func updateExcludeUI(animated: Bool){
        noEmptyGamesSwitch.setOn(filter.excludeEmptyGames, animated: animated)
        noExtensionsSwitch.setOn(filter.excludeExtensions, animated: animated)
    }
    
    private func setupRating(){
        ratingSlider = DoubleSlider(frame: .zero, maxValue: 100, minValue: 1, thumbColor: #colorLiteral(red: 0.4921983402, green: 0.6199769, blue: 0.7437539657, alpha: 1) , trackColor: ThemeManager.colorForUIelementsBackground(trait: traitCollection))
        
        ratingSlider.delegate = self
        ratingSlider.translatesAutoresizingMaskIntoConstraints = false
        ratingSliderContainer.addSubview(ratingSlider)
        NSLayoutConstraint.activate([
            ratingSlider.topAnchor.constraint(equalTo: ratingSliderContainer.topAnchor),
            ratingSlider.leadingAnchor.constraint(equalTo: ratingSliderContainer.leadingAnchor, constant: 20),
            ratingSlider.trailingAnchor.constraint(equalTo: ratingSliderContainer.trailingAnchor, constant: -20),
            ratingSlider.bottomAnchor.constraint(equalTo: ratingSliderContainer.bottomAnchor, constant: -20),
            ratingSlider.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        updateRatingUI(animated: false)
    }
    
    private func setupNavigationBar(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.plain, target: self, action: #selector(clearFilter))
        navigationItem.leftBarButtonItem?.tintColor = ThemeManager.colorForBarButtons(trait: traitCollection)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(closeVC))
        navigationItem.rightBarButtonItem?.tintColor = ThemeManager.colorForBarButtons(trait: traitCollection)
    }
    
    @objc private func closeVC() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupControls() {
        genreControl.setup(name: "Genre")
        themeControl.setup(name: "Theme")
        platformControl.setup(name: "Platform")
        
        morePlatformsButton.setTitleColor( ThemeManager.colorForPlainButtons(trait: traitCollection), for: .normal)
        morePlatformsButton.setTitleColor(ThemeManager.colorForPlainButtons(trait: traitCollection).withAlphaComponent(0.5), for: .highlighted)
    }
    
    private func updateReleaseDateUI(animated: Bool){
        let minDate = Date(timeIntervalSince1970: 0)
        let maxDate = Date(timeIntervalSince1970: 2147400000)
        
        dateLowerBound.minimumDate = minDate
        dateUpperBound.maximumDate = maxDate

        if let lowerBound = filter.releaseDateLowerBound{
            lowerDateBoundSwitch.setOn(true, animated: animated)
            dateLowerBound.date = lowerBound
            dateUpperBound.minimumDate = lowerBound
            
            dateLowerBound.isHidden = false
            UIView.animate(withDuration: 0.3){
                self.dateLowerBound.alpha = 1
            }
            
        } else {
            lowerDateBoundSwitch.setOn(false, animated: animated)
            UIView.animate(withDuration: 0.3, animations: {
                self.dateLowerBound.alpha = 0
            }) {
                _ in
                self.dateLowerBound.isHidden = true
            }
        }
        
        if let upperBound = filter.releaseDateUpperBound{
            upperDateBoundSwitch.setOn(true, animated: animated)
            dateUpperBound.date = upperBound
            dateLowerBound.maximumDate = upperBound
            dateUpperBound.isHidden = false
            UIView.animate(withDuration: 0.3){
                self.dateUpperBound.alpha = 1
            }
            
        } else {
            upperDateBoundSwitch.setOn(false, animated: animated)
            UIView.animate(withDuration: 0.3, animations: {
                self.dateUpperBound.alpha = 0
            }) {
                _ in
                self.dateUpperBound.isHidden = true
            }
        }
    }
    
    private func clearFlows() {
        genreFlow.removeAllSubviews()
        themeFlow.removeAllSubviews()
        platformFlow.removeAllSubviews()
    }
    
    
    
    private func updateFlows() {
        clearFlows()
        for genre in SearchFilter.allGenres{
            guard let name = genre.name, let id = genre.id else {continue}
            let attrView = GameAttributeView()
            let color = ThemeManager.colorForGenreAttribute(trait: traitCollection)
            attrView.setup(text: name, color: color, selectedNow: filter.genres.contains(genre))
            attrView.setupActions()
            attrView.addTarget(self, action: #selector(genreTapped), for: .touchUpInside)
            attrView.tag = id
            attrView.translatesAutoresizingMaskIntoConstraints = false
            genreFlow.addSubview(attrView)
        }
        for theme in SearchFilter.allThemes{
            guard let name = theme.name, let id = theme.id else {continue}
            let attrView = GameAttributeView()
            let color = ThemeManager.colorForThemeAttribute(trait: traitCollection)
            attrView.setup(text: name, color: color, selectedNow: filter.themes.contains(theme))
            attrView.setupActions()
            attrView.addTarget(self, action: #selector(themeTapped), for: .touchUpInside)
            attrView.tag = id
            attrView.translatesAutoresizingMaskIntoConstraints = false
            themeFlow.addSubview(attrView)
        }
        for platform in SearchFilter.mainPlatforms{
            guard let id = platform.id, let name = platform.name else {continue}
            let attrView = GameAttributeView()
            let color = ThemeManager.colorForPlatformAttribute(trait: traitCollection)
            attrView.setup(text: name, color: color, selectedNow: filter.platforms.contains(platform))
            attrView.setupActions()
            attrView.addTarget(self, action: #selector(platformTapped), for: .touchUpInside)
            attrView.tag = id
            attrView.translatesAutoresizingMaskIntoConstraints = false
            platformFlow.addSubview(attrView)
        }
    }

    private func setupFlows(){
        genreFlow.superview?.isHidden = true
        genreFlow.alpha = 0
        themeFlow.superview?.isHidden = true
        themeFlow.alpha = 0
        platformFlow.superview?.isHidden = true
        platformFlow.alpha = 0

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

        clear(gameAttrs: genreAttrs + themeAttrs + platformAttrs)
        
        if ratingSwitch.isOn { updateRatingUI(animated: true) }
        updateGameModesUI()
        updateReleaseDateUI(animated: true)
        updateExcludeUI(animated: true)
    }
    
    private func clear(gameAttrs: [GameAttributeView]){
        for attr in gameAttrs{
            attr.clear(animated: true)
        }
    }
    
    
    private func updateRatingUI(animated: Bool){
        if let upperValue = filter.ratingUpperBound, let lowerValue = filter.ratingLowerBound {
            ratingLabel.text = "\(lowerValue) - \(upperValue)"
            ratingSwitch.setOn(true, animated: animated)
            show(section: ratingSliderContainer, subview: ratingSlider, animated: animated)
            ratingLabel.isHidden = false
            ratingSlider.lowerValue = CGFloat(lowerValue)
            ratingSlider.upperValue = CGFloat(upperValue)
            ratingSlider.updateAppeareance()
            UIView.animate(withDuration: 0.3){
                self.ratingLabel.alpha = 1
            }
        } else {
            ratingSwitch.setOn(false, animated: animated)
            hide(section: ratingSliderContainer, subview: ratingSlider, animated: animated)
            UIView.animate(withDuration: 0.3, animations: {
                self.ratingLabel.alpha = 0
            }){
                _ in
                self.ratingLabel.isHidden = true
            }
        }
    }
}

extension FilterViewController: DoubleSliderDelegate{
    
    func sliderValuesChanged(newLowerValue: CGFloat, newUpperValue: CGFloat) {
        ratingLabel.text = "\(Int(newLowerValue)) - \(Int(newUpperValue))"
        filter.ratingUpperBound = Int(newUpperValue)
        filter.ratingLowerBound = Int(newLowerValue)
        
    }
    
}
