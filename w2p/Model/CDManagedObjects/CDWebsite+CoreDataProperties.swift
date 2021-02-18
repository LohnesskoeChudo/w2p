//
//  CDWebsite+CoreDataProperties.swift
//  w2p
//
//  Created by vas on 18.02.2021.
//
//

import Foundation
import CoreData


extension CDWebsite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDWebsite> {
        return NSFetchRequest<CDWebsite>(entityName: "CDWebsite")
    }

    @NSManaged public var id: Int64
    @NSManaged public var url: String?
    @NSManaged public var gameItmes: NSSet?

}

// MARK: Generated accessors for gameItmes
extension CDWebsite {

    @objc(addGameItmesObject:)
    @NSManaged public func addToGameItmes(_ value: CDGameItem)

    @objc(removeGameItmesObject:)
    @NSManaged public func removeFromGameItmes(_ value: CDGameItem)

    @objc(addGameItmes:)
    @NSManaged public func addToGameItmes(_ values: NSSet)

    @objc(removeGameItmes:)
    @NSManaged public func removeFromGameItmes(_ values: NSSet)

}

extension CDWebsite : Identifiable {

}
