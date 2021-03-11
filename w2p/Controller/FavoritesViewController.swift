//
//  FavoritesViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class FavoritesViewController: UIViewController{
    
    var favoritesFilter = SearchFilter()
    var mediaDispatcher = GameMediaDispatcher()
    var games: [Game] = []
    
    
    @IBAction func searchFieldValueChanged(_ sender: UITextField) {
        
        
    }
    
    
    @IBAction func resetTapped(_ sender: CustomButton) {
    }
    
    @IBOutlet weak var resetButton: CustomButton!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchTextFieldBackground: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupAppearance()
    }
    
    private func setupAppearance(){
        resetButton.setup(colorPressed: UIColor.lightGray.withAlphaComponent(0.15), colorReleazed: UIColor.lightGray.withAlphaComponent(0.3))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureFavorites()
        setupSearchBar()
    }
    
    private func captureFavorites(with search: String? = nil) {
        searchBar.isHidden = true
        hideInfoMessage(animated: false)
        cleanGames()
        self.mediaDispatcher.loadFavoriteGames{
            games in
            if let games = games, !games.isEmpty {
                
                self.games = games
                if let searchRequest = search {
                    self.filterGames(search: searchRequest)
                }
                
                if !self.games.isEmpty {
                    self.prepareGamesForShowing(completion: self.showGames)
                } else {
                    self.showEmptyResultMessage()
                }
                
            } else {
                self.showNoFavoritesAtAllMessage()
            }
        }
    }
    
    private func filterGames(search: String){
        
    }
    
    private func cleanGames(){
        games = []
        tableView.reloadData()
        tableView.isScrollEnabled = false
    }
    
    private func showEmptyResultMessage(){
        showInfo(message: "No results")
    }
    
    private func showNoFavoritesAtAllMessage(){
        showInfo(message: "You have no games in favorites yet")
    }
    
    private func showInfo(message: String) {
        DispatchQueue.main.async {
            self.messageTextLabel.text = message
            self.messageTextLabel.isHidden = false
            UIView.animate(withDuration: 0.3){
                self.messageTextLabel.alpha = 1
            }
        }

    }
    
    private func hideInfoMessage(animated: Bool, completion: (() -> Void)? = nil){
        let action = {
            self.messageTextLabel.alpha = 0
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: action) {
                _ in
                self.messageTextLabel.isHidden = true
                completion?()
            }
        } else {
            action()
            self.messageTextLabel.isHidden = true
            completion?()
        }
    }
    
    
    
    private func setupSearchBar(){
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
        searchTextField.delegate = self
        searchTextFieldBackground.layer.cornerRadius = searchTextFieldBackground.frame.height / 2
        searchTextFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    

    private func prepareGamesForShowing(completion: () -> Void){
        DispatchQueue.main.async { self.tableView.isScrollEnabled = true }
        self.games.sort{
            fGame, sGame in
            if let fd = fGame.cacheDate, let sd = sGame.cacheDate {
                return fd < sd
            }
            return true
        }
        completion()
    }

    private func showGames(){
        DispatchQueue.main.async {
            self.searchBar.isHidden = false
            UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil )
        }
    }
    
    private func setupTableView(){
        tableView.dataSource = self
    }
    
    private func startLoadingAnimation(){
        
    }
    
    private func endLoadingAnimation(){
        
    }
}

extension FavoritesViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteGameCell = tableView.dequeueReusableCell(withIdentifier: "gameFavoriteCell", for: indexPath) as! FavoriteGameCardCell
        
        let game = games[indexPath.row]
        setup(favoriteGameCell, with: game)
        
        return favoriteGameCell
    }
    
    private func setup(_ cell: FavoriteGameCardCell, with game: Game) {
        cell.label.text = game.name
        cell.id = game.id ?? 0
        cell.setupRatingView(with: game.totalRating)
        loadImage(for: cell, game: game)
    }
    
    private func loadImage(for cell: FavoriteGameCardCell, game: Game){
        guard let cover = game.cover else { return }
        let id = cell.id
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.mediaDispatcher.fetchCoverDataWith(cover: cover, cache: true) {
                data, error in
                if let data = data {
                    if let image = UIImage(data: data) {
                        let resizedImage = ImageResizer.resizeImageToFit(width: FavoriteGameCardCell.imageWidth, image: image)
                        DispatchQueue.main.async {
                            if id != cell.id {return}
                            UIView.transition(with: cell.gameImageView, duration: 0.1, options: .transitionCrossDissolve) {
                                
                                
                                cell.gameImageView.image = resizedImage
                                
                            }
                        }
                    }
                }
            }
        }
    }
}


extension FavoritesViewController: UITableViewDelegate{
    
    
    
}

extension FavoritesViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
