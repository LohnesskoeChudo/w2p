//
//  GameBrowserDelegate.swift
//  w2p
//
//  Created by vas on 26.02.2021.
//

import UIKit

protocol GameBrowser {
    var games: [Game] {get}
    var mediaDispatcher: GameMediaDispatcher {get}
    var columnWidth: CGFloat {get}
    var collectionView: UICollectionView! {get set}
}



class GameBrowserDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, WaterfallCollectionViewLayoutDelegate {
    
    init(browser: GameBrowser & NSObject) {
        self.browser = browser
    }
    
    unowned var browser: GameBrowser & NSObject
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.browser.games.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! GameCardCell
        
        let game = browser.games[indexPath.item]
        configureCell(cardCell, game: game)
        setCoverToCardCell(cardCell, game: game)
        cardCell.reusing = true
        return cardCell
    }
    
    func configureCell(_ cell: GameCardCell, game: Game){
        cell.id = game.id ?? -1
        cell.customContent.label.text = game.name
        cell.action = { [weak self] in
            if let vc = self?.browser as? UIViewController{
                vc.performSegue(withIdentifier: "detailed", sender: game)
            }
        }
    }
    
    func setCoverToCardCell(_ cell: GameCardCell, game: Game){
        let id = game.id ?? -1
        DispatchQueue.global().async {
            self.browser.mediaDispatcher.fetchCoverFor(game: game, cache: true){
                data, error in
                if let data = data {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            let columnWidth = self.browser.columnWidth
                            DispatchQueue.global().async {
                                let resizedImage = ImageResizer.resizeImageToFit(width: columnWidth, image: image)
                                DispatchQueue.main.async{
                                    if cell.id == id{
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
    
    func heightForPhoto(at indexPath: IndexPath) -> CGFloat {
        let gameItem = browser.games[indexPath.item]
        
        
        let height = ((browser.collectionView.frame.width - CGFloat((numberOfColumns + 1)) * spacing) / CGFloat(numberOfColumns)) * CGFloat((gameItem.cover?.aspect ?? 0))
        
        var additionHeight: CGFloat = CardViewComponentsHeight.name.rawValue

        return height + additionHeight
    }
    var numberOfColumns: Int {
        guard let vc = self.browser as? UIViewController else {return 0}
        return vc.traitCollection.horizontalSizeClass == .compact ? 2 : 3 }
    
    var spacing: CGFloat {
        10
    }
}
