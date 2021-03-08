//
//  DetailedViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class DetailedViewController: UIViewController{
    
    var game: Game!
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
    
    
    @IBOutlet weak var mediaCounterBackground: UIView!
    @IBOutlet weak var mediaCounterLabel: UILabel!
    @IBOutlet weak var blurredMediaBackground: UIImageView!
    @IBOutlet weak var mediaCollectionView: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var blurredBackground: UIImageView!
    @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverHeightConstraint: NSLayoutConstraint!
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
            sender.backgroundColor = .blue
            game.inFavorites = false
        } else {
            sender.backgroundColor = .black
            game.inFavorites = true
        }
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
        setupNameLabel()
        setupGameAttributesViews()
        setupCover()
        setupSummaryLabel()
        setupStorylineLabel()
        setupNavigationButtons()
        setupMedia()
        setupSecondaryInfo()
        setupWebsites()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutCover(size: view.frame.size)
        layoutMedia(newWidth: view.frame.width)
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
        if let sites = game.websites {
            if !sites.isEmpty {
                var websiteButtons = [UIView]()
                for website in sites {
                    if let button = setupWebsiteButton(website: website) {
                        websiteButtons.append(button)
                    }
                }
                if !websiteButtons.isEmpty {
                    websitesOpeningButton.nameLabel.text = "Websites"
                    setupWebsitesFlow(with: websiteButtons)
                    websitesFlowView.superview!.isHidden = true
                    return
                }
            }
        }
        websitesOpeningButton.isHidden = true
        websitesFlowView.superview!.isHidden = true
    }
    
    private func setupWebsiteButton(website: Website) -> UIView?{
        guard let siteCategory = website.category, let url = website.url, let websiteName = WebsiteCategory(rawValue: siteCategory)?.name else { return nil }
        let commonButton = CustomButton()
        commonButton.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = websiteName
        commonButton.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: commonButton.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: commonButton.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: commonButton.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: commonButton.bottomAnchor, constant: -5)
        ])
        return commonButton
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
        screenshotCollectionViewHeight.constant = newWidth * 500 / 889
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
        var gameAttrs: [GameAttributeView] = []
        for genre in game.genres ?? [] {
            let genreAttr = GameAttributeView()
            genreAttr.setup(text: genre.name ?? "", color: UIColor.red.withAlphaComponent(0.2))
            gameAttrs.append(genreAttr)
        }
        for theme in game.themes ?? [] {
            let themeAttr = GameAttributeView()
            themeAttr.setup(text: theme.name ?? "", color: UIColor.green.withAlphaComponent(0.2))
            gameAttrs.append(themeAttr)
        }
        for mode in game.gameModes ?? []{
            let modeAttr = GameAttributeView()
            modeAttr.setup(text: mode.name ?? "", color: UIColor.blue.withAlphaComponent(0.2))
            gameAttrs.append(modeAttr)
        }
        for platform in game.platforms ?? [] {
            let platformAttr = GameAttributeView()
            platformAttr.setup(text: platform.name ?? "", color: UIColor.purple.withAlphaComponent(0.2))
            gameAttrs.append(platformAttr)
        }
        for attrView in gameAttrs{
            attrView.translatesAutoresizingMaskIntoConstraints = false
            attributesFlowView.addSubview(attrView)
        }
    }
   
    private func setupCover(){
        guard let cover = game.cover, let gameId = game.id else { return }
        let viewWidth = view.bounds.width
        DispatchQueue.global(qos: .userInitiated).async{
            self.mediaDispatcher.fetchCoverDataWith(cover: cover, gameId: gameId, cache: true) {
                data, error in
                if let data = data, let image = UIImage(data: data){
                    let blurred = self.imageBlurrer.blurImage(with: image, radius: 30)
                    let resizedBlurred = ImageResizer.resizeImageToFit(width: viewWidth, image: blurred)
                        
                    DispatchQueue.main.async {
                        UIView.transition(with: self.coverView, duration: 0.2, options: .transitionCrossDissolve){
                            
                            self.coverView.image = image
                        }
                        
                        UIView.transition(with: self.blurredBackground, duration: 0.2, options: .transitionCrossDissolve){
                            self.blurredBackground.image = resizedBlurred
                        }
                        
                        if self.isMediaSectionAvailable {
                            self.blurredMediaBackground.image = resizedBlurred
                        }
                    }
                }
            }
        }
    }
    
    private func layoutCover(size: CGSize){
        
        let heightPercentage: CGFloat = 0.58

        guard let aspect = game.cover?.aspect else {return}
        if CGFloat(aspect) > (size.height * heightPercentage) / size.width {
            coverHeightConstraint.constant = size.height * heightPercentage
            coverWidthConstraint.constant = (1 / CGFloat(aspect)) * (size.height * heightPercentage)
            
        } else {
            coverWidthConstraint.constant = size.width
            coverHeightConstraint.constant = size.width * CGFloat(aspect)
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
        
        CGSize(width: view.bounds.width, height: view.bounds.height * 500 / 889 )
        
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
        mediaDispatcher.fetchStaticMedia(with: staticMedia, gameId: game.id ?? -1) {
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
