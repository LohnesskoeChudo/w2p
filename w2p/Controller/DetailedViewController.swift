//
//  DetailedViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class DetailedViewController: UIViewController{
    
    var game: Game!
    var shouldUpdate: Bool = false

    var mediaDispatcher = GameMediaDispatcher()
    var imageBlurrer = ImageBlurrer()
    var staticMediaContent = [MediaDownloadable]()
    var videoMediaContent = [Video]()
    
    var isMediaSectionAvailable: Bool {
        if let videos = game.videos, !videos.isEmpty {
            return true
        }
        if let screenshots = game.screenshots, !screenshots.isEmpty {
            return true
        }
        if let artworks = game.artworks, !artworks.isEmpty {
            return true
        }
        return false
    }
    
    
    
    
    @IBOutlet weak var ratingVIew: LineRatingView!
    
    @IBOutlet weak var firstReleaseContainer: UIView!
    @IBOutlet weak var firstReleaseLabel: UILabel!
    @IBOutlet weak var statusContainer: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var categoryContainer: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var companyContainer: UIView!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var gameEngineContainer: UIView!
    @IBOutlet weak var gameEngineLabel: UILabel!
    @IBOutlet weak var websitesOpeningButton: CategoryShowButton!
    @IBOutlet weak var websitesFlowView: LabelFlowView!
    @IBOutlet weak var favoritesButtonImage: UIImageView!
    @IBOutlet weak var mediaCounterBackground: UIView!
    @IBOutlet weak var mediaCounterLabel: UILabel!
    @IBOutlet weak var blurredMediaBackground: UIImageView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var blurredBackground: UIImageView!
    
    
    @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabelTopSpacing: NSLayoutConstraint!
    @IBOutlet weak var coverBottomSpacing: NSLayoutConstraint!
    
    
    @IBOutlet weak var screenshotCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var storylineLabel: UILabel!
    @IBOutlet weak var attributesContainer: UIView!
    @IBOutlet weak var attributesFlowView: LabelFlowView!
    @IBOutlet weak var similarGamesButton: TransferButton!
    @IBOutlet weak var franchiseGamesButton: TransferButton!
    @IBOutlet weak var collectionGamesButton: TransferButton!
    
    @IBAction func shareButtonTapped(_ sender: CustomButton) {
        performActivity()
        
    }
    
    private func performActivity(){
        DispatchQueue.global(qos: .userInteractive).async {
            let dispatchGroup = DispatchGroup()
            var activityItems = [Any]()

            
            if let websiteStr = self.game.websites?.first?.url, let siteUrl = URL(string: websiteStr) {
                activityItems.append(siteUrl)
            }
            
            if let name = self.game.name {
                if let description = self.game.summary {
                    activityItems.append("\(name)\n\n\(description)")
                } else {
                    activityItems.append(name)
                }
            }
            
            dispatchGroup.enter()
            DispatchQueue.global(qos: .userInteractive).async {
                if let cover = self.game.cover {
                    self.mediaDispatcher.fetchStaticMedia(with: cover, completion: {
                        data, error in
                        if let data = data , let image = UIImage(data: data){
                            activityItems.append(image)
                        }
                        dispatchGroup.leave()
                    })
                } else {
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.main, work: DispatchWorkItem(block: {
                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                activityVC.isModalInPresentation = true
                self.present(activityVC, animated: true, completion: nil)
            }))
        }
    }
    
    @IBAction func websitesOpeningButtonTapped(_ sender: CategoryShowButton) {
        UIView.animate(withDuration: 0.3) {
            self.websitesFlowView.superview?.isHidden.toggle()
        }
    }
    
    
    
    @IBAction func similarGamesTapped(_ sender: TransferButton) {
        performSegue(withIdentifier: "browser", sender: BrowserGameCategory.similarGames)
    }
    @IBAction func franchiseGamesTapped(_ sender: TransferButton) {
        performSegue(withIdentifier: "browser", sender: BrowserGameCategory.franchiseGames)
    }
    @IBAction func collectionGamesTapped(_ sender: TransferButton) {
        performSegue(withIdentifier: "browser", sender: BrowserGameCategory.collectionGames)
    }
    @IBAction func backButtonPressed(_ sender: CustomButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func toFavoritesTapped(_ sender: CustomButton) {

        if game.inFavorites == true {
            game.inFavorites = false
        } else {
            game.inFavorites = true
        }
        updateFavoritesButton(animated: true)
        mediaDispatcher.save(game: game)
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        case "browser":
            guard let browserVC = segue.destination as? SimilarGamesController, let gameCategory = sender as? BrowserGameCategory else {return}

            browserVC.externalGame = game
            browserVC.category = gameCategory
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if shouldUpdate {
            //updateGame()
        }
        print(game.cover)
        setupUI()
        
    }
    
    // set favorites
    private func updateGame() {
        guard let id = game.id else { return }
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2) {
            self.mediaDispatcher.updateGame(id: id)
        }
    }
    
    private func setupUI(){
        updateFavoritesButton(animated: false)
        setupNameLabel()
        setupRating()
        setupGameAttributesViews()
        setupCover()
        setupSummaryLabel()
        setupStorylineLabel()
        setupNavigationButtons()
        setupMedia()
        setupSecondaryInfo()
        setupWebsites()
    }
    
    
    private func setupRating(){
        if let rating = game.totalRating, rating > 0 {
            ratingVIew.rating = rating
        } else {
            ratingVIew.superview?.isHidden = true
        }
    }
    
    private func setupGameMetadata(completion: @escaping (_ success: Bool)->Void){
        guard let id = game.id else { return }
        DispatchQueue.global(qos: .userInteractive).async {
            self.mediaDispatcher.loadGame(with: id) {
                dbGame, error in
                if let dbGame = dbGame {
                    self.game.inFavorites = dbGame.inFavorites
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func setupUIAfterLoadingGameMetadata() {
        updateFavoritesButton(animated: true)
    }
    
    
    private func updateFavoritesButton(animated: Bool) {
        DispatchQueue.main.async {
            let action = {
                self.favoritesButtonImage.tintColor = (self.game.inFavorites ?? false) ? UIColor.yellow : UIColor.gray
                
            }
            if animated {
                UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState){
                    action()
                }
            } else {
                action()
            }
        }
    }
    
    
   
    override func viewWillAppear(_ animated: Bool) {
        layoutCover(size: view.frame.size)
        layoutMedia(newWidth: view.frame.width)
        setupGameMetadata() {
            success in
            if success {
                self.updateFavoritesButton(animated: true)
            }
        }
    }
    

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        layoutCover(size: size)
        layoutMedia(newWidth: size.width)
        if isMediaSectionAvailable {
            mediaCollectionView.contentOffset.x = 0
        }
    }
    

    private func setupMedia(){
        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        
        

        if let screenshots = game.screenshots {
            staticMediaContent += screenshots
        }
        if let artworks = game.artworks {
            staticMediaContent += artworks
        }
        if staticMediaContent.count + videoMediaContent.count == 0 {
            mediaContainer.isHidden = true
        } else {
            setupMediaCounter()
        }

    }
    
    private func setupSecondaryInfo(){
        
        if let releaseDate = game.firstReleaseDate{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let dateStr = dateFormatter.string(from: releaseDate)
            firstReleaseLabel.text = dateStr
        } else {
            firstReleaseContainer.isHidden = true
        }

        if let status = game.status {
            statusLabel.text = GameStatus(rawValue: status)?.toString()
        } else {
            statusContainer.isHidden = true
        }
        
        if let category = game.category {
            categoryLabel.text = GameCategory(rawValue: category)?.toString()
        } else {
            categoryContainer.isHidden = true
        }
        
        if let companies = game.involvedCompanies?.compactMap({$0.company}){
            let lowerIdCompany = companies.min(by: { first, second in (first.id ?? 0) < (second.id ?? 0)})
            companyLabel.text = lowerIdCompany?.name

        } else {
            companyContainer.isHidden = true
        }
        
        if let engines = game.gameEngines {
            let lowerIdEngine = engines.min(by: {first, second in (first.id ?? 0) < (second.id ?? 0)})
            gameEngineLabel.text = lowerIdEngine?.name
        } else {
            gameEngineContainer.isHidden = true
        }
    }
    
    private func setupWebsites(){
        websitesFlowView.superview?.isHidden = true
        if let sites = game.websites {
            if !sites.isEmpty {
                var websiteButtons = [UIView]()
                for (index,website) in sites.enumerated() {
                    if let button = setupWebsiteButton(website: website, index: index) {
                        websiteButtons.append(button)
                    }
                }
                if !websiteButtons.isEmpty {
                    websitesOpeningButton.nameLabel.text = "Websites"
                    setupWebsitesFlow(with: websiteButtons)
                    websitesOpeningButton.superview?.isHidden = false
                    return
                }
            }
        }
        websitesOpeningButton.superview?.isHidden = true
    }
    
    private func setupWebsiteButton(website: Website, index: Int) -> UIView?{
        guard let siteCategory = website.category, let websiteName = WebsiteCategory(rawValue: siteCategory)?.name else { return nil }
        let button = CustomButton()
        button.tag = index
        let buttonColorReleased = ThemeManager.colorForWebsite(trait: traitCollection)
        let buttonColorPressed = ThemeManager.darkVersion(of: buttonColorReleased)
        button.setup(colorPressed: buttonColorPressed, colorReleazed: buttonColorReleased)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(websiteButtonPressed(sender:)), for: .touchUpInside)
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = websiteName
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize + 3, weight: .semibold)
        button.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: button.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -5)
        ])
        return button
    }
    
    @objc private func websiteButtonPressed(sender: CustomButton) {
        guard let urlStr = game.websites?[sender.tag].url, let url = URL(string: urlStr) else {return}
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func setupWebsitesFlow(with views: [UIView]){
        for view in views {
            websitesFlowView.addSubview(view)
        }
        websitesFlowView.setNeedsLayout()
        websitesFlowView.layoutIfNeeded()
    }
    
    private func setupMediaCounter(){
        mediaCounterBackground.layer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        let height = mediaCounterBackground.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        mediaCounterBackground.layer.cornerRadius = height / 2
        updateMediaCounter()
        
    }
    
    private func layoutMedia(newWidth: CGFloat) {
        screenshotCollectionViewHeight.constant = floor(newWidth * 500 / 889) + 1
        mediaCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupNavigationButtons(){
        if game.similarGames != nil{
            similarGamesButton.textLabel.text = "Similar games"
        } else {
            similarGamesButton.superview?.isHidden = true
        }
        if game.franchise?.games != nil{
            franchiseGamesButton.textLabel.text = "Franchise games"
        } else {
            franchiseGamesButton.superview?.isHidden = true
        }
        if game.collection?.games != nil{
            collectionGamesButton.textLabel.text = "Collection games"
        } else {
            collectionGamesButton.superview?.isHidden = true
        }
    }
    
    private func setupNameLabel(){
        if let gameName = game.name{
            nameLabel.text = gameName
            nameLabel.font = UIFont.boldSystemFont(ofSize: 25)
        } else {
            nameLabel.superview?.isHidden = true
        }
    }
    
    private func setupSummaryLabel(){
        if let summary = game.summary{
            summaryLabel.text = summary
        } else {
            summaryLabel.superview?.isHidden = true
        }
    }
    
    private func setupStorylineLabel(){
        if let storyline = game.storyline{
            storylineLabel.text = storyline
        } else {
            storylineLabel.superview?.isHidden = true
        }
    }
    
    private func setupGameAttributesViews(){
        for subview in attributesFlowView.subviews {
            subview.removeFromSuperview()
        }
        var gameAttrs: [GameAttributeView] = []
        for genre in game.genres ?? [] {
            let genreAttr = GameAttributeView()
            let color = ThemeManager.colorForGenreAttribute(trait: traitCollection)
            genreAttr.setup(text: genre.name ?? "", color: color)
            gameAttrs.append(genreAttr)
        }
        for theme in game.themes ?? [] {
            let themeAttr = GameAttributeView()
            let color = ThemeManager.colorForThemeAttribute(trait: traitCollection)
            themeAttr.setup(text: theme.name ?? "", color: color)
            gameAttrs.append(themeAttr)
        }
        for mode in game.gameModes ?? []{
            let modeAttr = GameAttributeView()
            let color = ThemeManager.colorForGameModeAttribute(trait: traitCollection)
            modeAttr.setup(text: mode.name ?? "", color: color)
            gameAttrs.append(modeAttr)
        }
        for platform in game.platforms ?? [] {
            let platformAttr = GameAttributeView()
            let color = ThemeManager.colorForPlatformAttribute(trait: traitCollection)
            platformAttr.setup(text: platform.name ?? "", color: color)
            gameAttrs.append(platformAttr)
        }
        
        if gameAttrs.isEmpty {
            attributesContainer.isHidden = true
        } else {
            for attrView in gameAttrs{
                attrView.translatesAutoresizingMaskIntoConstraints = false
                attributesFlowView.addSubview(attrView)
            }
        }
    }
   
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupGameAttributesViews()
    }
    
    
    private func setupCover(){
        guard let cover = game.cover else {
            setDefaultAppearance()
            coverHeightConstraint.constant = 0
            coverBottomSpacing.constant = 0
            nameLabelTopSpacing.constant = 0
            return
        }
        
        let viewWidth = view.bounds.width
        loadCover(cover: cover) {
            image in
            guard let image = image else {
                self.setDefaultAppearance()
                return
            }
            
            let resized = ImageResizer.resizeImageToFit(width: viewWidth, image: image)
            let resizedBlurred = self.imageBlurrer.blurImage(with: image, radius: 30)
            
            
            //let blurred = self.imageBlurrer.blurImage(with: image, radius: 30)
            //let resizedBlurred = ImageResizer.resizeImageToFit(width: viewWidth / 2, image: blurred)

            DispatchQueue.main.async {
                UIView.transition(with: self.coverView, duration: 0.2, options: .transitionCrossDissolve){
                    self.coverView.image = resized
                }
                
                UIView.transition(with: self.blurredBackground, duration: 0.6, options: [.transitionCrossDissolve, .curveEaseOut]){
                    self.blurredBackground.image = resizedBlurred
                }
                
                if self.isMediaSectionAvailable {
                    self.blurredMediaBackground.image = resizedBlurred
                }
            }
        }
    }
    
    private func setDefaultAppearance() {
        if isMediaSectionAvailable {
            DispatchQueue.main.async {
                let width = self.view.frame.width / 2
                DispatchQueue.global(qos: .userInteractive).async{
                    let backgroundImage = UIImage(named: "mediaBackgound")!
                    let resized = ImageResizer.resizeImageToFit(width: width, image: backgroundImage)
                    let blurred = self.imageBlurrer.blurImage(with: resized, radius: 10)
                    DispatchQueue.main.async {
                        self.blurredMediaBackground.image = blurred
                    }
                }
            }
        }
    }
    
    private func loadCover(cover: Cover, completion: ((UIImage?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async{
            self.mediaDispatcher.fetchStaticMedia(with: cover) {
                data, error in
                if let data = data {
                    completion?(UIImage(data: data))
                } else {
                    completion?(nil)
                }
            }
        }
    }
    
    

    
    private func setupPlaceholderBlurredBackgroundForMediaSectionIfNeeded() {
        
        
        
    }
    
    private func layoutCover(size: CGSize){
        
        let heightPercentage: CGFloat = 0.58
        
            let padding:CGFloat = 20

        guard let aspect = game.cover?.aspect else {return}
        if CGFloat(aspect) > (size.height * heightPercentage) / size.width {
            
            coverHeightConstraint.constant = size.height * heightPercentage
            coverWidthConstraint.constant = (1 / CGFloat(aspect)) * (size.height * heightPercentage)
            
        } else {
            print("CAAALED")
            let width = size.width - (2 * padding)
            
            coverWidthConstraint.constant = width
            coverHeightConstraint.constant = width * CGFloat(aspect)
        }
    }
    
    private func updateMediaCounter(){
        let xOffset = mediaCollectionView.contentOffset.x
        let width = mediaCollectionView.frame.width
        
        let pageNumber = Int(xOffset / width) + 1
        mediaCounterLabel.text = "\(pageNumber) / \(staticMediaContent.count + videoMediaContent.count)"
        
        
    }
}


extension DetailedViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.bounds.width, height: view.bounds.width * 500 / 889 )
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateMediaCounter()
    }

}

extension DetailedViewController: UICollectionViewDataSource{
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        staticMediaContent.count + videoMediaContent.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
      //  if indexPath.item >= videoMediaContent.count{
            
            
            let staticMediaCell = collectionView.dequeueReusableCell(withReuseIdentifier: "staticMediaCell", for: indexPath) as! StaticMediaCell
            
            let staticMedia = staticMediaContent[indexPath.item - videoMediaContent.count]
            staticMediaCell.id = staticMedia.id
            setStaticContent(staticMedia: staticMedia, cell: staticMediaCell)
            return staticMediaCell
            
            
       // } else {
            
        //}
        
    }
    
    func setStaticContent(staticMedia: MediaDownloadable, cell: StaticMediaCell){
        
        let id = cell.id
        let width = mediaCollectionView.frame.width
        mediaDispatcher.fetchStaticMedia(with: staticMedia) {
            (data: Data?, error: FetchingError?) in
            if let data = data{
                DispatchQueue.global(qos: .userInteractive).async{
                    guard let image = UIImage(data: data) else {
                        
                        return
                        
                    }
                    
                    let resizedImage = ImageResizer.resizeImageToFit(width: width, image: image)
                    
                    DispatchQueue.main.async {
                        if id == cell.id {
                            UIView.transition(with: cell.staticMediaView, duration: 0.3, options: .transitionCrossDissolve) {
                                cell.staticMediaView.image = resizedImage
                            }
                        }
                    }
                }
            }
            if let error = error {
            }
        }
    }
    
    
    
    
    
}

enum BrowserGameCategory {
    case similarGames, franchiseGames, collectionGames
}
