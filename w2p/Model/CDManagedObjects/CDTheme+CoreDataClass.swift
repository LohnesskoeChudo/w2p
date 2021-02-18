//
//  CDTheme+CoreDataClass.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData

@objc(CDTheme)
public class CDTheme: NSManagedObject {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, theme: GameTheme) {
        self.init(entity: entity, insertInto: context)
        id = Int64(theme.id)
        name = theme.name
    }
}
