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

class GameBrowserDelegate: NSObject, UICollectionViewDataSource{
    
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
        cell.action = { [weak browser] in
            if let vc = browser as? UIViewController{
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
