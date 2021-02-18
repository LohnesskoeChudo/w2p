//
//  CDCover+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDCover)
public class CDCover: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, cover: GameImage) {
        
        self.init(entity: entity, insertInto: context)
        
        width = Int64(cover.width)
        height = Int64(cover.height)
        image = cover.data
        url = cover.basicUrlStr
        id = Int64(cover.id)

    }
}
