//
//  CDCollection+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDCollection)
public class CDCollection: NSManagedObject {
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, collection: GameCollection) {
        
        self.init(entity: entity, insertInto: context)
        gameIds = collection.gameIds
        id = Int64(collection.id)
        name = collection.name
        
    }
}
