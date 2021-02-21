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
        
        self.name = gameMode.name
    }
    
}
