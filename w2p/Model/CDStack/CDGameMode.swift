//
//  CDGameMode.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

public class CDGameMode: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, gameMode: GameMode){
            
        guard let id = gameMode.id else { return nil }
        guard let name = gameMode.name else { return nil }
        self.init(entity: entity, insertInto: context)
        self.id = Int64(id)
        self.name = name
    }
    
}

extension GameMode {
    convenience init?(cdGameMode: CDGameMode) {
        self.init()
        self.id = Int(cdGameMode.id)
        self.name = cdGameMode.name
    }
}
