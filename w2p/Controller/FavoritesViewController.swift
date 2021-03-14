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
    var allFavoriteGames: [Game] = []
    
    
    
    @IBAction func searchTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        captureFavorites(animated: true, with: searchTextField.text)
    }
    

    @IBAction func resetTapped(_ sender: CustomButton) {
        captureFavorites(animated: true)
        searchTextField.text = ""
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
        searchBar.isHidden = false
        searchBar.alpha = 0
        captureFavorites(animated: false)
        setupSearchBar()
    }
    
    private func captureFavorites( animated: Bool, with search: String? = nil) {
        hideInfoMessage(animated: animated)
        cleanGames(animated: animated){
            self.mediaDispatcher.loadFavoriteGames{
                games in
                if let games = games, !games.isEmpty {
                    self.allFavoriteGames = games
                    if let searchRequest = search {
                        self.filterGames(search: searchRequest)
                    } else {
                        self.games = self.allFavoriteGames
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
    }
    

    private func filterGames(search: String){
        self.games = []
        let search = search.lowercased()
        for game in allFavoriteGames{
            if let name = game.name, name.lowercased().index(of: search) != nil {
                self.games.append(game)
            }
        }
    }
    
    private func cleanGames(animated: Bool, completion: @escaping () -> Void ){
        allFavoriteGames = []
        games = []
        let action = { self.tableView.reloadData() }
        if animated {
            UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
                action()
            }) {
                _ in
                completion()
            }
        } else {
            action()
            completion()
        }
        tableView.isScrollEnabled = false
    }
    
    private func showEmptyResultMessage(){
        DispatchQueue.main.async {
            self.searchBar.isHidden = false
        }
        showInfo(message: "No results")
    }
    
    private func showNoFavoritesAtAllMessage(){
        DispatchQueue.main.async {
            self.searchBar.isHidden = true
        }
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
        self.games.sort{
            fGame, sGame in
            if let fd = fGame.cacheDate, let sd = sGame.cacheDate {
                return fd < sd
            }
            return true
        }
        DispatchQueue.main.async {
            self.tableView.isScrollEnabled = true
            self.searchBar.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.searchBar.alpha = 1
            }
        }
        completion()
    }

    private func showGames(){
        DispatchQueue.main.async {
            UIView.transition(with: self.tableView, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                self.tableView.reloadData()
            }, completion: nil )
        }
    }
    
    private func setupTableView(){
        tableView.dataSource = self
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


extension FavoritesViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
