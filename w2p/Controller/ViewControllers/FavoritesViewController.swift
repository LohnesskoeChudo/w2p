//
//  FavoritesViewController.swift
//  w2p
//
//  Created by vas on 13.02.2021.
//

import UIKit

class FavoritesViewController: UIViewController{
    
    private let mediaDispatcher = Resolver.shared.container.resolve(PMediaDispatcher.self)!
    private let cacheManager = Resolver.shared.container.resolve(PCacheManager.self)!
    private var games: [Game] = []
    private var allFavoriteGames: [Game] = []

    @IBOutlet private weak var resetButton: CustomButton!
    @IBOutlet private weak var messageTextLabel: UILabel!
    @IBOutlet private weak var searchBar: UIView!
    @IBOutlet private weak var searchTextFieldBackground: UIView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    @IBAction private func searchTapped(_ sender: UIButton) {
        FeedbackManager.generateFeedbackForButtonsTapped()
        captureFavorites(animated: true, with: searchTextField.text)
    }

    @IBAction private func resetTapped(_ sender: CustomButton) {
        captureFavorites(animated: true)
        searchTextField.text = ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "favoritesToDetailed":
            let destination = segue.destination as! DetailedViewController
            let game = sender as! Game
            destination.shouldUpdate = true
            destination.game = game
        default:
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAnimations), name: UIApplication.didBecomeActiveNotification, object: nil)
        setupTableView()
        setupAppearance()
    }
    
    @objc private func updateAnimations() {
        for cell in tableView.visibleCells{
            let gameCell = cell as! FavoriteGameCardCell
            if gameCell.isLoading {
                gameCell.startContentLoadingAnimation()
            }
        }
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
        cleanGames(animated: animated) {
            self.cacheManager.loadFavoriteGames {
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
    
    private func filterGames(search: String) {
        self.games = []
        let search = search.lowercased()
        for game in allFavoriteGames {
            if let name = game.name, name.lowercased().index(of: search) != nil {
                self.games.append(game)
            }
        }
    }
    
    private func cleanGames(animated: Bool, completion: @escaping () -> Void ) {
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
    
    private func showEmptyResultMessage() {
        DispatchQueue.main.async {
            self.searchBar.isHidden = false
        }
        showInfo(message: "No results")
    }
    
    private func showNoFavoritesAtAllMessage() {
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
    
    private func setupSearchBar() {
        searchBar.layer.cornerRadius = searchBar.frame.height / 2
        searchTextField.delegate = self
        searchTextFieldBackground.layer.cornerRadius = searchTextFieldBackground.frame.height / 2
        searchTextFieldBackground.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    }
    
    private func prepareGamesForShowing(completion: () -> Void) {
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

    private func showGames() {
        DispatchQueue.main.async {
            UIView.transition(with: self.tableView, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                self.tableView.reloadData()
            }, completion: nil )
        }
    }
    
    private func setupTableView() {
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
        cell.setActionToControl { [weak self] in
            self?.performSegue(withIdentifier: "favoritesToDetailed", sender: game)
        }
        loadImage(for: cell, game: game)
    }
    
    private func loadImage(for cell: FavoriteGameCardCell, game: Game) {
        guard let cover = game.cover else { return }
        let id = cell.id
        cell.isLoading = true
        cell.startContentLoadingAnimation()
        self.mediaDispatcher.fetchPreparedToSetStaticMedia(with: cover, targetWidth: FavoriteGameCardCell.imageWidth, sizeKey: .S264X374) {
            image, error in
            DispatchQueue.main.async {
                if id != cell.id {return}
                cell.gameImageView.image = image
                UIView.animate(withDuration: 0.3) {
                    cell.gameImageView.alpha = 1
                } completion: { _ in
                    cell.isLoading = false
                    cell.endContentLoadingAnimation()
                }
            }
        }
    }
}

extension FavoritesViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
