//
//  CDPlatform.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData
class CDPlatform: NSManagedObject{
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, platform: Platform){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(platform.id)
        self.name = platform.name
    }
}

extension Platform {
    init?(cdPlatform: CDPlatform) {
        self.id = Int(cdPlatform.id)
        if let platformName = cdPlatform.name {
            self.name = platformName
        } else {
            return nil
        }
    }
}
