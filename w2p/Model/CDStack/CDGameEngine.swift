//
//  CDGameEngine.swift
//  w2p
//
//  Created by vas on 06.03.2021.
//

import CoreData

class CDGameEngine: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, gameEngine: GameEngine){
        guard let id = gameEngine.id else { return nil }
        guard let name = gameEngine.name else { return nil }
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.id = Int64(id)
    }
}

extension GameEngine {
    convenience init? (cdGameEngine: CDGameEngine){
        self.init()
        self.id = Int(cdGameEngine.id)
        self.name = cdGameEngine.name
    }
}
