//
//  ViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit
class SearchViewController: UIViewController {
    
    var searchedGameItems = [GameItem]()
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
        let request = RequestFormer.shared.formRequestForSearching(filter: SearchFilter())
        let completion = {
            (jsonGameItems: [JSONGame]?, error: NetworkError?) in
            if let jsonGameItems = jsonGameItems {
                let itemsCount = self.searchedGameItems.count
                let newItemsCount = jsonGameItems.count
                let indexPaths = (itemsCount..<itemsCount+newItemsCount).map{IndexPath(item: $0, section: 0)}
                DispatchQueue.main.async {
                    self.searchedGameItems += jsonGameItems.map{GameItem(jsonGame: $0)}
                    UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]){
                    self.collectionView.insertItems(at: indexPaths)
                    }
                }
            }
        }
        jsonLoader.load(request: request, completion: completion)
    }
    @IBAction func filterTapped(_ sender: UIButton) {
        collectionView.setNeedsLayout()
        collectionView.layoutIfNeeded()
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
            let detailedVC = segue.destination as! DetailedViewController

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
        let gameItem = searchedGameItems[indexPath.item]
        
        
        let height = ((collectionView.frame.width - CGFloat((numberOfColumns + 1)) * spacing) / CGFloat(numberOfColumns)) * CGFloat((gameItem.cover?.aspect ?? 0))
        
        var additionHeight: CGFloat = CardViewComponentsHeight.name.rawValue
        

        if let rating = gameItem.aggregatedRating, rating > 0 {
            additionHeight += CardViewComponentsHeight.rating.rawValue
        }
        if gameItem.genres?.first != nil{
            additionHeight += CardViewComponentsHeight.genre.rawValue
        }
        
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
        self.searchedGameItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! GameCardCell
        
        let gameItem = searchedGameItems[indexPath.item]
        configureCell(cardCell, gameItem: gameItem)
        setCoverToCardCell(cardCell, gameItem: gameItem)
        cardCell.reusing = true
        return cardCell
    }
    
    func configureCell(_ cell: GameCardCell, gameItem: GameItem){
        cell.id = gameItem.name
        if let genre = gameItem.genres?.first {
            cell.genreLabel.text = genre.name
        } else {
            cell.genreLabel.superview!.isHidden = true
        }
        cell.nameLabel.text = gameItem.name
        cell.coverImageView.backgroundColor = .red
        if !cell.reusing {
            cell.action = { [weak self] in
                if let vc = self{
                    vc.performSegue(withIdentifier: "detailed", sender: nil)
                }
            }
        }
    }
    
    func setCoverToCardCell(_ cell: GameCardCell, gameItem: GameItem){
        let id = gameItem.name
        DispatchQueue.global().async {
            self.mediaDispatcher.fetchCover(gameItem: gameItem){
                data in
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


