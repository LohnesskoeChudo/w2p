//
//  CDFranchise.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDFranchise: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, franchise: Franchise){
            
        guard let id = franchise.id else { return nil }
        guard let name = franchise.name else { return nil }
        guard let games = franchise.games else { return nil }

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

extension Franchise {
    convenience init? (cdFranchise: CDFranchise) {
        self.init()
        self.id = Int(cdFranchise.id)
        self.name = cdFranchise.name
        if let games = (cdFranchise.games?.sortedArray(using: [])) as? [CDGame] {
            self.games = games.map{Int($0.id)}
        } else {
            return nil
        }
    }
}
