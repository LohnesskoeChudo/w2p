//
//  ViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit
class SearchViewController: UIViewController {
    
    var searchedGames = [Game]()
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
                let itemsCount = self.searchedGames.count
                let newItemsCount = games.count
                let indexPaths = (itemsCount..<itemsCount+newItemsCount).map{IndexPath(item: $0, section: 0)}
                DispatchQueue.main.async {
                    self.searchedGames += games
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLayoutSubviews()
        setupSearchField()
        setupButtons()
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        collectionView.delegate = self
        collectionView.dataSource = self
        if let waterfallLayout = collectionView.collectionViewLayout as? WaterfallCollectionViewLayout{
            waterfallLayout.delegate = self
        }
    }
    
    func setupSearchField(){
        searchField.delegate = self
        searchFieldBackground.layer.cornerRadius = searchFieldBackground.frame.height / 2
        searchFieldBackground.backgroundColor = UIColor.lightGray
    }
    
    func setupButtons(){
        searchButton.adjustsImageWhenHighlighted = true
    }
    

}
// MARK: - collectionView delegate
extension SearchViewController: UICollectionViewDelegate, WaterfallCollectionViewLayoutDelegate{

    func heightForPhoto(at indexPath: IndexPath) -> CGFloat {
        let gameItem = searchedGames[indexPath.item]
        
        
        let height = ((collectionView.frame.width - CGFloat((numberOfColumns + 1)) * spacing) / CGFloat(numberOfColumns)) * CGFloat((gameItem.cover?.aspect ?? 0))
        
        var additionHeight: CGFloat = CardViewComponentsHeight.name.rawValue

        return height + additionHeight
    }
    var numberOfColumns: Int { traitCollection.horizontalSizeClass == .compact ? 2 : 3 }
    
    var spacing: CGFloat {
        10
    }
}

// MARK: - searchField delegate
extension SearchViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - data source
extension SearchViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.searchedGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! GameCardCell
        
        let game = searchedGames[indexPath.item]
        configureCell(cardCell, game: game)
        setCoverToCardCell(cardCell, game: game)
        cardCell.reusing = true
        return cardCell
    }
    
    func configureCell(_ cell: GameCardCell, game: Game){
        cell.id = game.id ?? -1
        cell.nameLabel.text = game.name
        cell.coverImageView.backgroundColor = .blue
        cell.action = { [weak self] in
            if let vc = self{
                vc.performSegue(withIdentifier: "detailed", sender: game)
            }
        }
    }
    
    func setCoverToCardCell(_ cell: GameCardCell, game: Game){
        let id = game.id ?? -1
        DispatchQueue.global().async {
            self.mediaDispatcher.fetchCoverFor(game: game, cache: true){
                data, error in
                if let data = data {
                    if let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            let columnWidth = self.columnWidth
                            DispatchQueue.global().async {
                                let resizedImage = self.imageResizer.resizeImageToFit(width: columnWidth, image: image)
                                DispatchQueue.main.async{
                                    if cell.id == id{
                                        cell.coverImageView.image = resizedImage
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


