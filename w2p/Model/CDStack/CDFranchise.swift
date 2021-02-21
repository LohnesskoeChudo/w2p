//
//  CDFranchise.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDFranchise: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, franchise: Franchise){
        
        self.init(entity: entity, insertInto: context)
        self.name = franchise.name
        self.id = Int64(franchise.id)
        
        var collectionGames = [CDGame]()
        for gameId in franchise.games{
            let game = CDGame(context: context)
            game.id = Int64(gameId)
            collectionGames.append(game)
        }
        self.games = NSSet(array: collectionGames)
    }
}
