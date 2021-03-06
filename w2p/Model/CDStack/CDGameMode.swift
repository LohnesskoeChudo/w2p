//
//  CDGameMode.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDGameMode: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, gameMode: GameMode){
        
        self.init(entity: entity, insertInto: context)
        self.id = Int64(gameMode.id)
        self.name = gameMode.name
    }
    
}

extension GameMode {
    init?(cdGameMode: CDGameMode) {
        self.id = Int(cdGameMode.id)
        if let gmName = cdGameMode.name {
            self.name = gmName
        } else {
            return nil
        }
    }
}
