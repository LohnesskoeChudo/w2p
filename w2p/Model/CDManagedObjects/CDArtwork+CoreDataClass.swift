//
//  CDArtwork+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDArtwork)
public class CDArtwork: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, artwork: GameImage) {

        self.init(entity: entity, insertInto: context)
        
        width = Int64(artwork.width)
        height = Int64(artwork.height)
        image = artwork.data
        url = artwork.basicUrlStr
        id = Int64(artwork.id)

    }
}
