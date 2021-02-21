//
//  CDGenre.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDGenre: NSManagedObject{
    
    convenience init(context: NSManagedObjectContext, entity: NSEntityDescription, genre: Genre){
        
        self.init(entity: entity, insertInto: context)
        
        self.id = Int64(genre.id)
        self.name = genre.name
    }
}
