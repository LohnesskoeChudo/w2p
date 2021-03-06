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
        
        favoriteGameCell.label.text = game.name
        favoriteGameCell.setupGameImageView(aspect: 1.2)
        favoriteGameCell.gameImageView.image = UIImage(named: "test")
        
        return favoriteGameCell
    }
    
    
    
    
}

extension FavoritesViewController: UITableViewDelegate{
    
}
