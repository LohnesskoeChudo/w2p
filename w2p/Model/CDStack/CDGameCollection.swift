//
//  CDGameCollection.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDGameCollection: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, collection: GameCollection){
            
        guard let id = collection.id else { return nil }
        guard let name = collection.name else { return nil }
        guard let games = collection.games else { return nil }
        
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.id = Int64(id)
        var collectionGames = [CDGame]()
        for gameId in games{
            let game = CDGame(context: context)
            game.id = Int64(gameId)
            collectionGames.append(game)
        }
        self.games = NSSet(array: collectionGames)
        
    }
}


//
extension GameCollection {
    convenience init? (cdGameCollection: CDGameCollection) {
        self.init()
        self.id = Int(cdGameCollection.id)
        self.name = cdGameCollection.name
        if let games = (cdGameCollection.games?.sortedArray(using: [])) as? [CDGame] {
            self.games = games.map{Int($0.id)}
        } else {
            return nil
        }
    }
}
