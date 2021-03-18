//
//  CDFranchise.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDFranchise: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, franchise: Franchise, generatorGame: CDGame){
            
        guard let id = franchise.id else { return nil }
        guard let name = franchise.name else { return nil }
        guard let games = franchise.games else { return nil }

        self.init(entity: entity, insertInto: context)
        self.name = name
        self.id = Int64(id)
        
        let gameEntity = NSEntityDescription.entity(forEntityName: "CDGame", in: context)!
        var franchiseGames = [CDGame]()
        for gameId in games{
            if Int64(gameId) == generatorGame.id {
                continue
            } else {
                let game = CDGame(entity: gameEntity, insertInto: context)
                game.id = Int64(gameId)
                franchiseGames.append(game)
            }
        }
        self.games = NSSet(array: franchiseGames)
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
