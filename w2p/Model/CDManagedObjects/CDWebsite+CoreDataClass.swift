//
//  CDWebsite+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDWebsite)
public class CDWebsite: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, website: GameWebsite) {
        
        self.init(entity: entity, insertInto: context)
        id = Int64(website.website?.rawValue ?? 0)
        url = website.url?.absoluteString ?? ""

    }
}
