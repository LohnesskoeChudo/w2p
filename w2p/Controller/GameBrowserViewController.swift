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
    
    var browserDelegate: GameBrowserDelegate!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var upperBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setupGestureRecognizers()
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
    
    func setupDelegates(){
        browserDelegate = GameBrowserDelegate(browser: self)
        collectionView.dataSource = browserDelegate
        collectionView.delegate = self
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = self
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
    
    private func setupGestureRecognizers(){
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panRecognizer.delegate = self
        collectionView.addGestureRecognizer(panRecognizer)

    }
    
    @objc func pan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            let yVelocity = sender.velocity(in: view).y
            print(yVelocity)
            if yVelocity > 1000 {
                if self.upperBar.isHidden {
                    self.upperBar.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.upperBar.alpha = 0.9
                    })
                }
            } else if yVelocity < -500 {
                if !self.upperBar.isHidden{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.upperBar.alpha = 0
                    }, completion: {
                        _ in
                        self.upperBar.isHidden = true
                    })
                }
            }
        default:
            return
        }
    }
    
}

// MARK: - Delegates
extension GameBrowserViewController: WaterfallCollectionViewLayoutDelegate{
    
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
        upperBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
}


extension GameBrowserViewController: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0{
            upperBar.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.upperBar.alpha = 0.9
            })
        }
    }
}

extension GameBrowserViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
