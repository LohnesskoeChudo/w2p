//
//  GameBrowserViewController.swift
//  w2p
//
//  Created by vas on 26.02.2021.
//

import UIKit
class GameBrowserViewController : UIViewController, GameBrowser{
    
    var externalGame: Game!
    var category: BrowserGameCategory!
    
    
    var games = [Game]()
    var mediaDispatcher = GameMediaDispatcher()
    var jsonLoader = JsonLoader()
    var columnWidth: CGFloat {
        (collectionView.collectionViewLayout as! WaterfallCollectionViewLayout).columnWidth
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadGames()
    }
    
    private func loadGames(){
        

        let request: URLRequest
        
        if category == .similarGames{
            request = RequestFormer.shared.requestForSimilarGames(for: externalGame)
        } else if category == .franchiseGames{
            request = RequestFormer.shared.formRequestForSpecificGames(externalGame.franchise?.games ?? [])
        } else {
            request = RequestFormer.shared.formRequestForSpecificGames(externalGame.collection?.games ?? [])
        }

        let completion = {
            (games: [Game]?, error: NetworkError?) in
            if let games = games {
                let itemsCount = self.games.count
                let newItemsCount = games.count
                let indexPaths = (itemsCount..<itemsCount+newItemsCount).map{IndexPath(item: $0, section: 0)}
                DispatchQueue.main.async {
                    self.games += games
                    UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]){
                    self.collectionView.insertItems(at: indexPaths)
                    }
                }
            }
        }
        jsonLoader.load(request: request, completion: completion)
    }
    
    func setup(){
        let browserDelegate = GameBrowserDelegate(browser: self)
        collectionView.dataSource = browserDelegate
        collectionView.delegate = browserDelegate
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = browserDelegate
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailed":
            let game = sender as! Game
            let detailedVC = segue.destination as! DetailedViewController
            detailedVC.game = game
        default:
            return
        }
    }
}
