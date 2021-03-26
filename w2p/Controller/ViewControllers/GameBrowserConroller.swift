//
//  GameBrowserConroller.swift
//  w2p
//
//  Created by vas on 03.03.2021.
//

import UIKit

class GameBrowserController: UIViewController, WaterfallCollectionViewLayoutDelegate {
    
    var gamesSource = FifoQueue<Game>()
    var games = [Game]()
    let searchFilter = SearchFilter()
    let jsonLoader = JsonLoader()
    let mediaDispatcher = GameMediaDispatcher()
    let imageResizer = ImageResizer()
    var columnWidth: CGFloat {
        (collectionView.collectionViewLayout as! WaterfallCollectionViewLayout).columnWidth
    }
    var footer: UIControl!
    var footerImageView: UIImageView!
    var gameApiRequestItem: GameApiRequestItem?
    var currentOffset = 0
    var feedStep = 50
    var gamesPerRequest = 500
    var isLoading = false
    var afterLoadApiItemAction: ((_ item: GameApiRequestItem) -> Void)?

    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    func refreshGames(withAnimation: Bool, completion: ((Bool) -> Void)? = nil) {
        
        let gamesWereEmpty = games.isEmpty
        isLoading = true
        games = []
        gamesSource.clear()
        currentOffset = 0
        gameApiRequestItem?.offset = 0
        
        UIView.transition(with: collectionView, duration: gamesWereEmpty ? 0 : 0.3, options: .transitionCrossDissolve) {
            let wfInvalidationContext = WFLayoutInvalidationContext()
            wfInvalidationContext.action = .rebuild
            self.collectionView.collectionViewLayout.invalidateLayout(with: wfInvalidationContext)

        } completion:  { _ in
            self.collectionView.contentOffset = .zero
            self.loadGames(withAnimation: true) { success in
                self.currentOffset += self.gamesPerRequest
                completion?(success)
            }
        }
    }
    
    
    

    func loadGames(withAnimation: Bool, completion: ((Bool) -> Void)? = nil){
        isLoading = true
        if games.isEmpty { collectionView.isScrollEnabled = false }
        guard let gameApiRequestItem = gameApiRequestItem else { return }
        let request = RequestFormer.shared.formRequest(with: gameApiRequestItem)
        
        let action = {
            (games: [Game]?, error: NetworkError?) in
            
            if error != nil {
                self.isLoading = false
                self.endAnimationsLoading() {
                    self.showInfoMessage(type: .connectionError) {
                        completion?(false)
                    }
                }
                return
            }
            
            if let games = games {
                if !games.isEmpty {
                    self.gamesSource.push(array: games)
                    self.endAnimationsLoading(){
                        self.appendToFeed(newGames: self.gamesSource.pop(numOfElements: self.feedStep), withAnimation: withAnimation){
                            
                            
                            self.afterLoadApiItemAction?(gameApiRequestItem)
                            
                            self.currentOffset += self.gamesPerRequest
                            self.gameApiRequestItem?.offset = self.currentOffset
                            
                            
                            completion?(true)
                            self.collectionView.isScrollEnabled = true
                            self.isLoading = false
                        }
                    }
                } else {
                    self.endAnimationsLoading{
                        self.showInfoMessage(type: .noResults){
                            completion?(false)
                            self.isLoading = false
                        }
                    }
                }
            }
        }
        
        hideInfoMessages() {
            self.startAnimationLoading(){
                self.jsonLoader.load(request: request, completion: action)
            }
        }
    }
    
    enum InfoMessage {
        case connectionError
        case noResults
    }
    
    func resetInfoContainer() {
        infoContainer.alpha = 0
        infoLabel.alpha = 1
        infoImageView.alpha = 1
        infoImageView.transform = .identity
    }
    
    private func showConnectionError(completion: (()->Void)? = nil) {
        if self.games.isEmpty {
            showConnectionErrorIfNoItemsPresented(completion: completion)
        } else {
            showConnectionErrorIfItemsPresented(completion: completion)
        }
    }
    
    private func showConnectionErrorIfNoItemsPresented(completion: (() -> Void)? = nil){
        infoImageView.image = UIImage(named: "connection")
        infoLabel.text = "No Internet connection"
        infoContainer.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.infoContainer.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
    
    // TODO: - implement
    private func showConnectionErrorIfItemsPresented(completion: (() -> Void)? = nil) {
        completion?()
    }
    

    private func showInfoMessage(type: InfoMessage, completion: (() -> Void)? = nil){
        switch type {
        case .connectionError:
            showConnectionError(completion: completion)
        case .noResults:
            showNoResultMessageIfNeeded(completion: completion)
        }
    }
    
    private func showNoResultMessageIfNeeded(completion: (()->Void)? = nil){
        if games.isEmpty {
            infoImageView.image = UIImage(named: "noResults")
            infoLabel.text = "No results"
            infoContainer.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.infoContainer.alpha = 1
            } completion: { _ in
                completion?()
            }
        }
    }

    
    private func hideInfoMessages(completion: (()->Void)? = nil ){
        if !infoContainer.isHidden {
            UIView.animate(withDuration: 0.3) {
                self.infoContainer.alpha = 0
            } completion: { _ in
                self.infoContainer.isHidden = true
                completion?()
            }
        } else {
            completion?()
        }
    }
    
    private func startAnimationLoading(completion: (()->Void)? = nil){
        infoLabel.alpha = 1
        infoImageView.alpha = 1
        if games.isEmpty {
            startAnimationLoadingWithNoItems(completion: completion)
        } else {
            startAnimationLoadingWithItems(completion: completion)
        }
    }
   
    private func startAnimationLoadingWithNoItems(completion: (()->Void)? = nil){
        
        infoLabel.text = "Loading"
        
        infoImageView.image = UIImage(named: "gamepad")
        infoContainer.alpha = 0
        infoContainer.isHidden = false
        let imageAnimation = GameAnimationSupporter.getRotationAnimation()
        imageAnimation.duration = 1
        imageAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        imageAnimation.autoreverses = true
        imageAnimation.repeatCount = .infinity
        infoImageView.layer.add(imageAnimation, forKey: "loading infoImage animation")
        
        let labelAnimation = CABasicAnimation(keyPath: "opacity")
        labelAnimation.duration = 0.7
        labelAnimation.fromValue = 1
        labelAnimation.toValue = 0.6
        labelAnimation.autoreverses = true
        labelAnimation.repeatCount = .infinity
        labelAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState]) {
            self.infoContainer.alpha = 1

        } completion: { _ in
            self.infoLabel.layer.add(labelAnimation, forKey: "loading label animation")
            completion?()
        }
    }
    
    private func endAnimationLoadingWithNoItems(completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            
            /*
            guard !self.infoContainer.isHidden else {
                completion?()
                return
            }*/
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState]) {
                self.infoContainer.alpha = 0
            } completion: { _ in
                self.infoLabel.layer.removeAllAnimations()
                self.infoImageView.layer.removeAllAnimations()
                self.infoContainer.isHidden = true
                completion?()
            }
        }
    }
    
    private func startAnimationLoadingWithItems(completion: (()->Void)? = nil){
        completion?()
    }
    
    private func endAnimationLoadingWithItems(completion: (()->Void)? = nil) {
        completion?()
    }
    
    
    private func endAnimationsLoading(completion: (()->Void)? = nil){
        if games.isEmpty {
            endAnimationLoadingWithNoItems(completion: completion)
        } else {
            endAnimationLoadingWithItems(completion: completion)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAnimations), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    

    func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = self
        }
        collectionView.register(HeaderWaterfallLayoutView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        collectionView.register(FooterWaterfallLayoutView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "footer")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAnimations()
    }
    
    @objc private func updateAnimations(){
        if self.isLoading {
            startAnimationLoading()
        }
        animateCellsIfNeeded()
    }
    
     private func animateCellsIfNeeded(){
        for subview in collectionView.subviews {
            if let gameCell = subview as? GameCardCell {
                if gameCell.isLoading {
                    gameCell.startContentLoadingAnimation()
                }
            }
        }
    }

    private func appendToFeed(newGames: [Game], withAnimation: Bool, completion: (()->Void)? = nil ){
        let indexPaths = (self.games.count..<self.games.count+newGames.count).map{IndexPath(item: $0, section: 0)}

        let action = {
            let wfInvalidationContext = WFLayoutInvalidationContext()
            wfInvalidationContext.action = .insertion
            wfInvalidationContext.indexPaths = indexPaths
            self.collectionView.collectionViewLayout.invalidateLayout(with: wfInvalidationContext)
            completion?()
        }
        
        DispatchQueue.main.async {
            self.games += newGames
            if withAnimation{
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]){
                    action()
                }
            } else {
                action()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            updateAnimations()
        }
    }

    //MARK: - LayoutDelegate

    func heightForCell(at indexPath: IndexPath) -> CGFloat {
        let gameItem = games[indexPath.item]
        let height = ((collectionView.frame.width - CGFloat((numberOfColumns + 1)) * spacing) / CGFloat(numberOfColumns)) * CGFloat((gameItem.cover?.aspect ?? 0))
        
        let additionHeight: CGFloat = CardViewComponentsHeight.name.rawValue
        return height + additionHeight
    }
    
    var numberOfColumns: Int {
        return traitCollection.horizontalSizeClass == .compact ? 2 : 3 }
    
    var spacing: CGFloat {
        10
    }
    
    var upperSpacing: CGFloat {
        0
    }

    var footerHeight: CGFloat {
        0
    }
    
    
}


extension GameBrowserController: UICollectionViewDelegate{

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == max(0,games.count - 10){
            if !isLoading{
                if gamesSource.isEmpty {
                    loadGames(withAnimation: true)
                } else {
                    appendToFeed(newGames: gamesSource.pop(numOfElements: self.feedStep),withAnimation: false)
                }
            }
        }
    }
}


extension GameBrowserController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let gameCardCell = cell as? GameCardCell, indexPath.item == 0 {
            gameCardCell.endContentLoadingAnimation()
        }
    }
    

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! GameCardCell
        let game = games[indexPath.item]
        configureCell(cardCell, game: game)
        setCoverToCardCell(cardCell, game: game)
        cardCell.reusing = true
        return cardCell
    }
    
    
    
    
    func configureCell(_ cell: GameCardCell, game: Game){
        cell.id = game.id ?? -1
        cell.customContent.label.text = game.name
        let action = { [weak self] in
            self?.performSegue(withIdentifier: "detailed", sender: game)
            return
        }
        cell.setActionToControl(action: action)
    }
    
    func setCoverToCardCell(_ cell: GameCardCell, game: Game){
        cell.customContent.imageView.alpha = 0
        guard let cover = game.cover else { return }
        cell.startContentLoadingAnimation()
        cell.isLoading = true
        let id = game.id ?? -1
        DispatchQueue.global().async {
            self.mediaDispatcher.fetchStaticMedia(with: cover){
                data, error in
                if let data = data {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            let columnWidth = self.columnWidth
                            DispatchQueue.global().async {
                                let resizedImage = ImageResizer.resizeImageToFit(width: columnWidth, image: image)
                                DispatchQueue.main.async{
                                    if cell.id == id{
                                        cell.customContent.imageView.image = resizedImage
                                        cell.isLoading = false
                                        UIView.animate(withDuration: 0.3) {
                                            cell.customContent.imageView.alpha = 1
                                        } completion: { _ in
                                            cell.endContentLoadingAnimation()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
