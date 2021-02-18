//
//  CDFranchise+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDFranchise)
public class CDFranchise: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, franchise: GameFranchise) {
        
        self.init(entity: entity, insertInto: context)
        gameIds = franchise.gameIds
        id = Int64(franchise.id)
        name = franchise.name
    }
}
