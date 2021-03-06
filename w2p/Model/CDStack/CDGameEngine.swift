//
//  CDGameEngine.swift
//  w2p
//
//  Created by vas on 06.03.2021.
//

import CoreData

class CDGameEngine: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, gameEngine: GameEngine){
        
        self.init(entity: entity, insertInto: context)
        self.name = gameEngine.name
        self.id = Int64(gameEngine.id)
    }
}

extension GameEngine {
    init? (cdGameEngine: CDGameEngine){
        self.id = Int(cdGameEngine.id)
        if let name = cdGameEngine.name {
            self.name = name
        } else {
            return nil
        }
    }
}
