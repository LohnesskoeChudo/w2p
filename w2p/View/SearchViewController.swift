//
//  ViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit
class SearchViewController: UIViewController, GameBrowser {

    var games = [Game]()
    let searchFilter = SearchFilter()
    let jsonLoader = JsonLoader()
    let mediaDispatcher = GameMediaDispatcher()
    let imageResizer = ImageResizer()
    var panGestureRecognizer: UIPanGestureRecognizer!
    var browserDelegate: GameBrowserDelegate!
    var columnWidth: CGFloat {
        (collectionView.collectionViewLayout as! WaterfallCollectionViewLayout).columnWidth
    }

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchFieldBackground: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    // MARK: - Actions
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let request = RequestFormer.shared.formRequestForSearching(filter: searchFilter, limit: 500)
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
    @IBAction func filterTapped(_ sender: UIButton) {

    }
    
    @IBAction func searchFieldEditingChanged(_ sender: UITextField) {
        
        searchFilter.searchString = sender.text
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupGestureRecognizers()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLayoutSubviews()
        setupSearchBar()
        setupButtons()
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "filter":
            let navigationVC = segue.destination as! UINavigationController
            let filterVC = navigationVC.viewControllers.first as! FilterViewController
            filterVC.filter = searchFilter
            
        case "detailed":
            let game = sender as! Game
            let detailedVC = segue.destination as! DetailedViewController
            detailedVC.game = game

        default:
            return
        }
    }
    
    func setupCollectionView(){
        let browserDelegate = GameBrowserDelegate(browser: self)
        self.browserDelegate = browserDelegate
        collectionView.delegate = self
        collectionView.dataSource = browserDelegate
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = self
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        (collectionView.collectionViewLayout as? WaterfallCollectionViewLayout)?.invalidateLayout()
    }
    
    func setupSearchBar(){
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
        searchBar.alpha = 0.9
        searchField.delegate = self
        searchFieldBackground.layer.cornerRadius = searchFieldBackground.frame.height / 2
        searchFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    }
    
    func setupButtons(){
        searchButton.adjustsImageWhenHighlighted = true
    }
    
    
    private func setupGestureRecognizers(){
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGestureRecognizer.delegate = self
        collectionView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func pan(sender: UIPanGestureRecognizer){
        switch sender.state {
        case .ended:
            let yVelocity = sender.velocity(in: view).y
            print(yVelocity)
            if yVelocity > 1000 {
                if self.searchBar.isHidden {
                    self.searchBar.isHidden = false
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchBar.alpha = 0.9
                    })
                }
            } else if yVelocity < -500 {
                if !self.searchBar.isHidden{
                    UIView.animate(withDuration: 0.3, animations: {
                        self.searchBar.alpha = 0
                    }, completion: {
                        _ in
                        self.searchBar.isHidden = true
                    })
                }
            }
        default:
            return
        }
    }
    

}

// MARK: - Delegates

extension SearchViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension SearchViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
}


extension SearchViewController: WaterfallCollectionViewLayoutDelegate{
    
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
        searchBar.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 10
    }
}


extension SearchViewController: UICollectionViewDelegate{
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0{
            self.searchBar.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.searchBar.alpha = 0.9
            })
        }
    }
}

