//
//  CDGameCollection.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDGameCollection: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, collection: GameCollection){
        
        self.init(entity: entity, insertInto: context)
        self.name = collection.name
        self.id = Int64(collection.id)
        
        var collectionGames = [CDGame]()
        for gameId in collection.games{
            let game = CDGame(context: context)
            game.id = Int64(gameId)
            collectionGames.append(game)
        }
        self.games = NSSet(array: collectionGames)
        
    }
}
