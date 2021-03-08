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

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!

    func loadGames(withAnimation: Bool){
        guard let gameApiRequestItem = gameApiRequestItem else { return }
        let request = RequestFormer.shared.formRequest(with: gameApiRequestItem)
        
        let completion = {
            (games: [Game]?, error: NetworkError?) in
            if let games = games {
                self.gamesSource.push(array: games)
                self.appendToFeed(newGames: self.gamesSource.pop(numOfElements: self.feedStep), withAnimation: withAnimation)
                if !games.isEmpty {
                    self.currentOffset += self.gamesPerRequest
                    self.gameApiRequestItem?.offset = self.currentOffset
                }
            }
        }
        jsonLoader.load(request: request, completion: completion)
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

    private func appendToFeed(newGames: [Game], withAnimation: Bool){
        let indexPaths = (self.games.count..<self.games.count+newGames.count).map{IndexPath(item: $0, section: 0)}
        DispatchQueue.main.async {
            self.games += newGames
            
            
            if withAnimation{
                UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]){
                    self.collectionView.insertItems(at: indexPaths)
                }
            } else {
                self.collectionView.insertItems(at: indexPaths)
            }
        }
    }


    func heightForCell(at indexPath: IndexPath) -> CGFloat {
        let gameItem = games[indexPath.item]
        let height = ((collectionView.frame.width - CGFloat((numberOfColumns + 1)) * spacing) / CGFloat(numberOfColumns)) * CGFloat((gameItem.cover?.aspect ?? 0))
        
        var additionHeight: CGFloat = CardViewComponentsHeight.name.rawValue
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
            if gamesSource.isEmpty {
                loadGames(withAnimation: true)
            } else {
                appendToFeed(newGames: gamesSource.pop(numOfElements: self.feedStep),withAnimation: false)
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
        cell.action = { [weak self] in
            self?.performSegue(withIdentifier: "detailed", sender: game)
        }
    }
    
    func setCoverToCardCell(_ cell: GameCardCell, game: Game){
        guard let cover = game.cover, let gameId = game.id else { return }
        let id = game.id ?? -1
        DispatchQueue.global().async {
            self.mediaDispatcher.fetchCoverDataWith(cover: cover,gameId: gameId, cache: true){
                data, error in
                if let data = data {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            let columnWidth = self.columnWidth
                            DispatchQueue.global().async {
                                let resizedImage = ImageResizer.resizeImageToFit(width: columnWidth, image: image)
                                DispatchQueue.main.async{
                                    print(cell.id, id)
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

