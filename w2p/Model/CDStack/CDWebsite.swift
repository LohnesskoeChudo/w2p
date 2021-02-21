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
