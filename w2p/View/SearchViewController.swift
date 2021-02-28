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
    var columnWidth: CGFloat {
        (collectionView.collectionViewLayout as! WaterfallCollectionViewLayout).columnWidth
    }

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLayoutSubviews()
        setupSearchField()
        setupButtons()
        if !navigationController!.navigationBar.isHidden{
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
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
        
        collectionView.delegate = browserDelegate
        collectionView.dataSource = browserDelegate
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = browserDelegate
        }
    }
    
    func setupSearchField(){
        searchField.delegate = self
        searchFieldBackground.layer.cornerRadius = searchFieldBackground.frame.height / 2
        searchFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    }
    
    func setupButtons(){
        searchButton.adjustsImageWhenHighlighted = true
    }
    

}

// MARK: - searchField delegate
extension SearchViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
