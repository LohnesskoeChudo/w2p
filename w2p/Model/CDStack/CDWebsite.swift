//
//  CDWebsite.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDWebsite: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, website: Website){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(website.id)
        self.url = website.url
        if let category = website.category { self.category = Int64(category)}
    }
    
}


extension Website {
    init?(cdWebsite: CDWebsite) {
        self.id = Int(cdWebsite.id)
        if let url = cdWebsite.url {
            self.url = url
        } else {
            return nil
        }
        self.category = Int(cdWebsite.category)
    }
}
