//
//  CDPlatform.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData
public class CDPlatform: NSManagedObject{
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, platform: Platform){
        
        guard let id = platform.id else { return nil }
        guard let name = platform.name else { return nil }
        self.init(entity: entity, insertInto: context)
        self.id = Int64(id)
        self.name = name
    }
}

extension Platform {
    convenience init?(cdPlatform: CDPlatform) {
        self.init()
        self.id = Int(cdPlatform.id)
        self.name = cdPlatform.name
    }
}
