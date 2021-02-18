//
//  CDGenre+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDGenre)
public class CDGenre: NSManagedObject {
    

    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, genre: GameGenre) {
        
        self.init(entity: entity, insertInto: context)
        id = Int64(genre.id)
        name = genre.name
        
    }
}
