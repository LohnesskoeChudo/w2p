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

extension Genre {
    init?(cdGenre: CDGenre) {
        self.id = Int(cdGenre.id)
        if let genreName = cdGenre.name {
            self.name = genreName
        } else {
            return nil
        }
    }
}
