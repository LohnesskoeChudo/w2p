//
//  CDGenre+CoreDataProperties.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData


extension CDGenre {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDGenre> {
        return NSFetchRequest<CDGenre>(entityName: "CDGenre")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var gameItems: NSSet?

}

// MARK: Generated accessors for gameItems
extension CDGenre {

    @objc(addGameItemsObject:)
    @NSManaged public func addToGameItems(_ value: CDGameItem)

    @objc(removeGameItemsObject:)
    @NSManaged public func removeFromGameItems(_ value: CDGameItem)

    @objc(addGameItems:)
    @NSManaged public func addToGameItems(_ values: NSSet)

    @objc(removeGameItems:)
    @NSManaged public func removeFromGameItems(_ values: NSSet)

}

extension CDGenre : Identifiable {

}
