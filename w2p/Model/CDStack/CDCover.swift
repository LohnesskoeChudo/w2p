//
//  CDCover.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDCover: NSManagedObject {
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, cover: Cover){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(cover.id)
        self.height = Int64(cover.height)
        self.width = Int64(cover.width)
        if let isAnimated = cover.animated { self.animated = isAnimated }
        self.url = cover.url
        
    }
    
}
