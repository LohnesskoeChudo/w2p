//
//  CDWebsite.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDWebsite: NSManagedObject {
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, website: Website){
            
        guard let id = website.id else { return nil }
        guard let url = website.url else { return nil }
        guard let category = website.category else { return nil }
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(id)
        self.url = url
        self.category = Int64(category)
    }
    
}


extension Website {
    convenience init?(cdWebsite: CDWebsite) {
        self.init()
        self.id = Int(cdWebsite.id)
        self.url = cdWebsite.url
        self.category = Int(cdWebsite.category)
    }
}
