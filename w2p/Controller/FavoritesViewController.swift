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
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewdidload")
        mediaDispatcher.loadFavoriteGames{
            games in
            if let games = games {
                DispatchQueue.main.async {
                    self.games = games
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func setupTableView(){
        tableView.delegate = self
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
        loadImage(for: cell, game: game)
    }
    
    private func loadImage(for cell: FavoriteGameCardCell, game: Game){
        guard let cover = game.cover,let gameId = game.id else { return }
        let id = cell.id
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.mediaDispatcher.fetchCoverDataWith(cover: cover, gameId: gameId, cache: true) {
                data, error in
                
                if let data = data {
                    

                    if let image = UIImage(data: data) {
                        let resizedImage = ImageResizer.resizeImageToFit(width: FavoriteGameCardCell.imageWidth, image: image)
                        DispatchQueue.main.async {
                            if id != cell.id {return}
                            UIView.transition(with: cell.gameImageView, duration: 0.3, options: .transitionCrossDissolve) {
                                
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
