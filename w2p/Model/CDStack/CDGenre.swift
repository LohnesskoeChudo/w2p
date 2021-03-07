//
//  CDGenre.swift
//  w2p
//
//  Created by vas on 20.02.2021.
//

import CoreData

class CDGenre: NSManagedObject{
    
    convenience init?(context: NSManagedObjectContext, entity: NSEntityDescription, genre: Genre){
        guard let id = genre.id else { return nil }
        guard let name = genre.name else { return nil }
        self.init(entity: entity, insertInto: context)
        self.id = Int64(id)
        self.name = name
    }
}

extension Genre {
    convenience init?(cdGenre: CDGenre) {
        self.init()
        self.id = Int(cdGenre.id)
        self.name = cdGenre.name
    }
}
