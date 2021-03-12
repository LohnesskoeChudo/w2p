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
        
    }
    
    private func endAnimationLoadingWithItems(completion: (()->Void)? = nil) {
        
    }
    
    
    private func endAnimationsLoading(completion: (()->Void)? = nil){
        endAnimationLoadingWithNoItems(completion: completion)
        endAnimationLoadingWithItems(completion: completion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = self
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (collectionView.collectionViewLayout as? WaterfallCollectionViewLayout)?.invalidateLayout()
    }

    private func appendToFeed(newGames: [Game], withAnimation: Bool, completion: (()->Void)? = nil ){
        let indexPaths = (self.games.count..<self.games.count+newGames.count).map{IndexPath(item: $0, section: 0)}
        
        let action = {
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
}


// MARK: - Delegates
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


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        games.count
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
        guard let cover = game.cover else { return }
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
                                        UIView.transition(with: cell.customContent.imageView, duration: 0.3, options: [.transitionCrossDissolve]){
                                            
                                            cell.customContent.imageView.image = resizedImage
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

