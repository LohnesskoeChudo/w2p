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
    
    
    @IBOutlet weak var searchBar: UIView!
    @IBOutlet weak var searchTextFieldBackground: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSearchBar()
        captureFavorites()
    }
    
    private func captureFavorites() {
        hideGames()
        startLoadingAnimation()
        mediaDispatcher.loadFavoriteGames{
            games in
            if let games = games {
                guard self.games != games else {
                    self.endLoadingAnimation()
                    self.showEmptyResultMessage()
                    return
                }
                
                if !games.isEmpty {
                    self.games = games
                    self.prepareGamesForShowing(completion: self.endLoadingAnimation)
                    self.showGames()
                } else {
                    self.endLoadingAnimation()
                    self.showEmptyResultMessage()
                }
            }
        }
    }
    
    
    private func showEmptyResultMessage(){
        
    }
    
    
    
    private func setupSearchBar(){
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
        searchTextField.delegate = self
        searchTextFieldBackground.layer.cornerRadius = searchTextFieldBackground.frame.height / 2
        searchTextFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    

    private func prepareGamesForShowing(completion: () -> Void){
        self.games.sort{
            fGame, sGame in
            if let fd = fGame.cacheDate, let sd = sGame.cacheDate {
                return fd < sd
            }
            return true
        }
    }
    
    private func hideGames(){
        tableView.alpha = 0
    }
    
    private func showGames(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
            UIView.animate(withDuration: 0.2) {
                self.tableView.alpha = 1
            }
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
