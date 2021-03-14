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

    // MARK: - Outets
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    func loadGames(withAnimation: Bool, completion: ((Bool) -> Void)? = nil){
        isLoading = true
        if games.isEmpty { collectionView.isScrollEnabled = false }
        guard let gameApiRequestItem = gameApiRequestItem else { return }
        let request = RequestFormer.shared.formRequest(with: gameApiRequestItem)
        
        let action = {
            (games: [Game]?, error: NetworkError?) in
            
            if error != nil {
                self.showConnectionError() {
                    completion?(false)
                }
                return
            }
            
            if let games = games, !games.isEmpty {
                self.gamesSource.push(array: games)
                self.endAnimationsLoading(){
                    
                    self.appendToFeed(newGames: self.gamesSource.pop(numOfElements: self.feedStep), withAnimation: withAnimation){
                        self.currentOffset += self.gamesPerRequest
                        self.gameApiRequestItem?.offset = self.currentOffset
                        completion?(true)
                        self.collectionView.isScrollEnabled = true
                        self.isLoading = false
                    }
                }
                return
            }
            
            self.endAnimationsLoading{
                self.showNoResultMessageIfNeeded(){
                    completion?(false)
                    self.isLoading = false
                }
            }
        }
        startAnimationLoading(){
            self.jsonLoader.load(request: request, completion: action)
        }
    }
    
    private func showConnectionError(completion: (()->Void)? = nil) {
        if self.games.isEmpty {
            showConnectionErrorIfNoItemsPresented(completion: completion)
        } else {
            showConnectionErrorIfItemsPresented(completion: completion)
        }
    }
    
    private func showConnectionErrorIfNoItemsPresented(completion: (() -> Void)? = nil){
        
    }
    
    private func showConnectionErrorIfItemsPresented(completion: (() -> Void)? = nil) {
        
    }
    
    private func showInfoMessage(){
        
    }
    
    private func showNoResultMessageIfNeeded(completion: (()->Void)? = nil){
        
    }
    
    private func hideInfoMessages(withAnimation: Bool, completion: (()->Void)? = nil ){
        
    }
    
    private func startAnimationLoading(completion: (()->Void)? = nil){
        if games.isEmpty {
            startAnimationLoadingWithNoItems(completion: completion)
        } else {
            startAnimationLoadingWithItems(completion: completion)
        }
    }
    
    private func startAnimationLoadingWithNoItems(completion: (()->Void)? = nil){
        infoContainer.isHidden = false
        infoContainer.alpha = 1
        let imageAnimation = CABasicAnimation(keyPath: "transform.rotation")
        imageAnimation.duration = 1
        imageAnimation.fromValue = CGFloat.pi / 4.5
        imageAnimation.toValue = -CGFloat.pi / 4.5
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

        infoImageView.isHidden = false
        UIView.animate(withDuration: 0.3){
            self.infoImageView.alpha = 1
        } completion: { _ in
            completion?()
        }
        
        infoLabel.text = "Loading"
        infoLabel.isHidden = false
        UIView.animate(withDuration: 0.7){
            self.infoLabel.alpha = 1
        } completion: { _ in
            self.infoLabel.layer.add(labelAnimation, forKey: "loading label animation")
        }
    }
    
    private func endAnimationLoadingWithNoItems(completion: (() -> Void)? = nil){
        DispatchQueue.main.async {
            guard !self.infoContainer.isHidden else {
                completion?()
                return
            }
            
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowAnimatedContent, .beginFromCurrentState]) {
                self.infoContainer.alpha = 0
            } completion: { _ in
                self.infoLabel.layer.removeAllAnimations()
                self.infoImageView.layer.removeAllAnimations()
                self.infoLabel.alpha = 0
                self.infoImageView.alpha = 0
                self.infoContainer.isHidden = true
                self.infoLabel.isHidden = true
                self.infoImageView.isHidden = true
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
    

    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = self
        }
        
        
    }
    


    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransition")
        (collectionView.collectionViewLayout as? WaterfallCollectionViewLayout)?.invalidateLayout()
        
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
            self.collectionView.insertItems(at: indexPaths)
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


// MARK: - Delegates
extension GameBrowserController: UICollectionViewDelegate{
    

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == max(0,games.count - 10){
            print("WILL DISPLAY AT \(indexPath.item)")
            if !isLoading{
                if gamesSource.isEmpty {
                    loadGames(withAnimation: true)
                } else {
                    appendToFeed(newGames: gamesSource.pop(numOfElements: self.feedStep),withAnimation: false)
                }
            }
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! GameBrowserFooter

        return footer
                
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
            self.mediaDispatcher.fetchCoverDataWith(cover: cover, cache: true){
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

