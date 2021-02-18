//
//  CDPlatform+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDPlatform)
public class CDPlatform: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, platform: GamePlatform) {
        
        self.init(entity: entity, insertInto: context)
        id = Int64(platform.id)
        name = platform.name
        
    }
}
