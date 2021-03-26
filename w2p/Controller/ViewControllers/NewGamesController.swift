//
//  NewGamesController.swift
//  w2p
//
//  Created by vas on 19.03.2021.
//

import UIKit

class NewGamesController: GameBrowserController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupRequestItem()
    }
    
    var initialLoad = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialLoad {
            refreshGames(withAnimation: true) {
                success in
            }
            initialLoad = false
        }
    }
    
    
   
    
    
    private func setupRequestItem() {
        gameApiRequestItem = GameApiRequestItem.formRequestItemForNewAvailableGames()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailed":
            let destinationVc = segue.destination as! DetailedViewController
            destinationVc.game = (sender as? Game)
        default:
            return
        }
    }
}
